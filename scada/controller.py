"""Central SCADA Controller bridging Python 21 CFR Part 11 Services with QML."""

from __future__ import annotations

from datetime import UTC, datetime
import json
from pathlib import Path
from typing import Any

from PySide6.QtCore import Property, QObject, QTimer, Signal, Slot

from scada.alarms import AlarmManager
from scada.audit import AuditEvent, AuditStore, utc_now
from scada.configuration import ConfigurationRegistry
from scada.cortex import CortexEngine
from scada.security import SecurityManager
from scada.simulation import PlantSimulator
from scada.store import HistorianStore, RecipeStore


class ScadaController(QObject):
    telemetryUpdated = Signal()
    alarmsUpdated = Signal()
    recipeStateUpdated = Signal()
    auditUpdated = Signal()
    batchListUpdated = Signal()

    def __init__(self, runtime_dir: Path, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self.runtime_dir = runtime_dir
        self.runtime_dir.mkdir(parents=True, exist_ok=True)

        config_dir = Path(__file__).resolve().parent / "config"
        self.registry = ConfigurationRegistry(config_dir)
        self.security = SecurityManager(self.registry)
        self.audit_store = AuditStore(self.runtime_dir / "audit.db", b"PVA_SYSTEMS_VPU50_SECRET_21CFR11_KEY_2026")
        self.historian = HistorianStore(self.runtime_dir / "historian.db")
        self.historian.initialise()
        self.recipe_store = RecipeStore(self.runtime_dir / "recipes.db")
        self.recipe_store.initialise()
        self.alarm_mgr = AlarmManager(self.registry, self.audit_store)
        self.simulator = PlantSimulator(Path(__file__).resolve().parent / "simulation" / "plant_profile.json")
        self.cortex = CortexEngine(self)

        # Current User Context
        self._current_user = "operator"
        self._current_role = "operator"

        # Current Telemetry State
        self._telemetry: dict[str, float] = self.simulator.step(0.0)

        # Active Batch & Recipe Execution State
        self._active_batch_id: str | None = None
        self._recipe_running: bool = False
        self._recipe_exec_state: dict[str, Any] = {
            "loaded": False,
            "recipeId": "",
            "recipeName": "",
            "currentStep": 0,
            "totalSteps": 0,
            "stepName": "",
            "stepDesc": "",
            "status": "IDLE",
            "elapsedSec": 0,
            "totalSec": 0,
            "confirmRequired": False,
            "confirmMessage": "",
        }

        # Seed initial standard recipes if store is empty
        self._seed_initial_recipes()

        # Seed sample historical batches for calendar view if empty
        self._seed_sample_batches()

        # Real-time Update Timer (500ms cycle)
        self.timer = QTimer(self)
        self.timer.timeout.connect(self._on_tick)
        self.timer.start(500)

        # Delta AS332T-A Modbus TCP Background Polling Worker
        from scada.modbus.worker import ModbusWorker
        self.modbus_worker = ModbusWorker(
            host="192.168.1.5",
            port=502,
            poll_interval_ms=100,
            enable_simulation_fallback=True,
            parent=self,
        )
        self.modbus_worker.telemetryPolled.connect(self._on_modbus_telemetry)
        self.modbus_worker.stepDoneSignaled.connect(self._on_modbus_step_done)
        self.modbus_worker.start()

    def _on_modbus_telemetry(self, telemetry: dict[str, Any]) -> None:
        self._telemetry.update({k: v for k, v in telemetry.items() if isinstance(v, (int, float))})
        self.telemetryUpdated.emit()

    def _on_modbus_step_done(self, completed_step: int) -> None:
        self.next_recipe_step(f"PLC_STEP_DONE_M34 (Step {completed_step})")

    def _seed_initial_recipes(self) -> None:
        if not self.recipe_store.list_recipes():
            body_lotion = {
                "name": "Body Lotion Formulation",
                "ingredients": [
                    {"sr": 1, "name": "DI Water", "phase": "A", "qty": "9.2 kg"},
                    {"sr": 2, "name": "EDTA Disodium", "phase": "A", "qty": "0.05 kg"},
                    {"sr": 3, "name": "Glycerine", "phase": "A", "qty": "2.0 kg"},
                    {"sr": 4, "name": "Light Liquid Paraffin", "phase": "B", "qty": "3.0 kg"},
                    {"sr": 5, "name": "Ceto Stearyl Alcohol", "phase": "B", "qty": "2.5 kg"},
                    {"sr": 6, "name": "SLES 70%", "phase": "C", "qty": "0.8 kg"},
                    {"sr": 7, "name": "Triethanolamine", "phase": "D", "qty": "0.3 kg"},
                ],
                "steps": [
                    {"id": 1, "name": "Fill DI Water", "desc": "Charge Phase A into reactor", "isManual": False, "duration": 60, "ops": [{"dev": "Fill Valve", "val": "50%"}]},
                    {"id": 2, "name": "Premix Phase A", "desc": "Agitate at 30 RPM", "isManual": False, "duration": 180, "ops": [{"dev": "Agitator", "val": "30 RPM"}]},
                    {"id": 3, "name": "Heat to 75°C", "desc": "Heat vessel under gentle stir", "isManual": False, "duration": 240, "ops": [{"dev": "Agitator", "val": "40 RPM"}, {"dev": "Heater", "val": "75°C"}]},
                    {"id": 4, "name": "Add Phase B (Oils)", "desc": "Charge oil phase manually", "isManual": True, "confirmMsg": "Confirm Phase B (Wax/Oils) charged into vessel.", "duration": 0, "ops": []},
                    {"id": 5, "name": "High-Shear Emulsify", "desc": "Run bottom homogenizer", "isManual": False, "duration": 300, "ops": [{"dev": "Homogenizer", "val": "3500 RPM"}, {"dev": "Agitator", "val": "50 RPM"}]},
                    {"id": 6, "name": "Vacuum Deaeration", "desc": "Pull vacuum -450 mbar", "isManual": False, "duration": 240, "ops": [{"dev": "Vacuum", "val": "-450 mbar"}, {"dev": "Agitator", "val": "30 RPM"}]},
                ],
            }
            self.recipe_store.save_recipe("REC-LOTION-01", 1, "Body Lotion Formulation", body_lotion, "System Admin")

    def _seed_sample_batches(self) -> None:
        if not self.historian.list_batches():
            # Seed 3 historical batches across past days
            b1 = self.historian.start_batch("REC-LOTION-01", "Body Lotion Formulation", 1, "Line Operator", "2026-08-15T09:00:00Z")
            self.historian.end_batch(b1["id"], "completed", "2026-08-15T10:45:00Z")
            # Write sample data points for b1
            for t_offset in range(0, 1800, 60):
                iso_t = datetime.fromtimestamp(1786784400 + t_offset, UTC).isoformat()
                self.historian.write_samples(b1["id"], {
                    "vpu.main.temperature": 25.0 + (t_offset / 1800.0) * 55.0,
                    "vpu.jacket.temperature": 28.0 + (t_offset / 1800.0) * 58.0,
                    "vpu.main.vacuum_pressure": -5.0 - (t_offset / 1800.0) * 450.0,
                    "vpu.main.agitator_speed": 35.0,
                    "vpu.main.homogenizer_speed": 2800.0 if t_offset > 600 else 0.0,
                }, iso_t)

    def _on_tick(self) -> None:
        self._telemetry = self.simulator.step(0.5)
        self.alarm_mgr.evaluate_telemetry(self._telemetry)

        # Record to Historian if batch active
        if self._active_batch_id:
            self.historian.write_samples(self._active_batch_id, self._telemetry)

        # Advance recipe step timers if running
        if self._recipe_exec_state["status"] == "RUNNING":
            self._recipe_exec_state["elapsedSec"] += 1
            if self._recipe_exec_state["totalSec"] > 0 and self._recipe_exec_state["elapsedSec"] >= self._recipe_exec_state["totalSec"]:
                self.next_recipe_step("AUTO_STEP_COMPLETE")
            self.recipeStateUpdated.emit()

        self.telemetryUpdated.emit()
        self.alarmsUpdated.emit()

    # --- Reactive Properties for QML Screen Binding & Lockout ---
    @Property(bool, notify=recipeStateUpdated)
    def recipeRunning(self) -> bool:
        return bool(self._recipe_running or (self._recipe_exec_state and self._recipe_exec_state.get("status") == "RUNNING"))

    @Property(str, notify=recipeStateUpdated)
    def activeBatchId(self) -> str:
        return self._active_batch_id or ""

    @Property(str, notify=recipeStateUpdated)
    def activeRecipeName(self) -> str:
        return self._recipe_exec_state.get("recipeName", "")

    @Property(int, notify=recipeStateUpdated)
    def currentStepIndex(self) -> int:
        return self._recipe_exec_state.get("currentStep", 0)

    @Property(int, notify=recipeStateUpdated)
    def totalSteps(self) -> int:
        return self._recipe_exec_state.get("totalSteps", 0)

    # --- QML Invocable Slots ---

    @Slot(str, str, result=bool)
    def loginUser(self, user_id: str, role_id: str) -> bool:
        self._current_user = user_id
        self._current_role = role_id
        self.audit_store.append(
            AuditEvent(
                timestamp_utc=utc_now(),
                actor_id=user_id,
                action="USER_AUTHENTICATED",
                object_type="USER_SESSION",
                object_id=user_id,
                reason="Operator logon",
                before={"role": "NONE"},
                after={"role": role_id},
                context={"client": "QML_SCADA_DESKTOP"},
            )
        )
        self.auditUpdated.emit()
        return True

    @Slot(str, float, str, result=bool)
    def setProcessSetpoint(self, tag_id: str, value: float, reason: str) -> bool:
        if self.recipeRunning:
            self.audit_store.append(
                AuditEvent(
                    timestamp_utc=utc_now(),
                    actor_id=self._current_user,
                    action="SECURITY_VIOLATION",
                    object_type="PROCESS_TAG",
                    object_id=tag_id,
                    reason=f"Attempted manual override while recipe active (Batch {self._active_batch_id})",
                    before={"value": self._telemetry.get(tag_id, 0.0)},
                    after={"rejected_value": value},
                    context={"violation": "RECIPE_LOCKOUT_ENFORCED"},
                )
            )
            self.auditUpdated.emit()
            raise PermissionError("Manual setpoint modifications are locked out while an automatic batch recipe is running.")

        tag = self.registry.get_tag(tag_id)
        if not tag:
            return False
        perm = tag.get("access", {}).get("command_permission")
        if perm:
            self.security.enforce(self._current_user, self._current_role, perm, f"Set {tag_id} to {value}")

        valid, msg = self.registry.validate_value(tag_id, value)
        if not valid:
            raise ValueError(msg)

        old_val = self._telemetry.get(tag_id, 0.0)
        self._telemetry[tag_id] = value
        if tag_id == "vpu.main.agitator_speed":
            self.simulator.target_agitator_speed = value
        elif tag_id == "vpu.main.homogenizer_speed":
            self.simulator.target_homogenizer_speed = value
        elif tag_id == "vpu.main.temperature":
            self.simulator.target_vessel_temp = value
            self.simulator.is_heating = value > self.simulator.vessel_temp
            self.simulator.is_cooling = value < self.simulator.vessel_temp
        elif tag_id == "vpu.main.vacuum_pressure":
            self.simulator.target_vacuum = value
            self.simulator.is_vacuum_on = value < -20.0

        self.audit_store.append(
            AuditEvent(
                timestamp_utc=utc_now(),
                actor_id=self._current_user,
                action="SETPOINT_MODIFIED",
                object_type="PROCESS_TAG",
                object_id=tag_id,
                reason=reason or "Manual process parameter adjustment",
                before={"value": old_val},
                after={"value": value},
                context={"unit": tag.get("unit")},
            )
        )
        self.auditUpdated.emit()
        return True

    @Slot(str, str, result=bool)
    def acknowledgeAlarm(self, alarm_id: str, comment: str) -> bool:
        self.security.enforce(self._current_user, self._current_role, "alarm.acknowledge", f"Acknowledge alarm {alarm_id}")
        self.alarm_mgr.acknowledge_alarm(alarm_id, self._current_user, comment)
        self.alarmsUpdated.emit()
        self.auditUpdated.emit()
        return True

    @Slot(str, result=str)
    def startBatch(self, recipe_id: str) -> str:
        self.security.enforce(self._current_user, self._current_role, "batch.execute", f"Start batch for {recipe_id}")
        recipes = self.recipe_store.list_recipes()
        selected = next((r for r in recipes if r["id"] == recipe_id), None)
        r_name = selected["name"] if selected else "Standard Batch"
        batch = self.historian.start_batch(recipe_id, r_name, 1, self._current_user)
        self._active_batch_id = batch["id"]
        self._recipe_running = True
        self._recipe_exec_state["status"] = "RUNNING"
        self._recipe_exec_state["recipeId"] = recipe_id
        self._recipe_exec_state["recipeName"] = r_name
        self._recipe_exec_state["currentStep"] = 1
        steps = selected.get("payload", {}).get("steps", []) if selected else []
        self._recipe_exec_state["totalSteps"] = len(steps) if steps else 6
        self.audit_store.append(
            AuditEvent(
                timestamp_utc=utc_now(),
                actor_id=self._current_user,
                action="BATCH_STARTED",
                object_type="BATCH",
                object_id=batch["id"],
                reason="Automatic recipe execution initiated",
                before={"batch_state": "NONE"},
                after={"batch_id": batch["id"], "recipe_id": recipe_id},
                context={"recipe_name": r_name},
            )
        )
        self.batchListUpdated.emit()
        self.recipeStateUpdated.emit()
        self.auditUpdated.emit()
        return batch["id"]

    @Slot(str, str, result=bool)
    def endBatch(self, batch_id: str, status: str) -> bool:
        self.security.enforce(self._current_user, self._current_role, "batch.execute", f"End batch {batch_id}")
        self.historian.end_batch(batch_id, status)
        self._active_batch_id = None
        self._recipe_running = False
        self._recipe_exec_state["status"] = "IDLE"
        self.audit_store.append(
            AuditEvent(
                timestamp_utc=utc_now(),
                actor_id=self._current_user,
                action="BATCH_ENDED",
                object_type="BATCH",
                object_id=batch_id,
                reason=f"Batch {status}",
                before={"batch_state": "RUNNING"},
                after={"batch_state": status},
                context={"user": self._current_user},
            )
        )
        self.batchListUpdated.emit()
        self.recipeStateUpdated.emit()
        self.auditUpdated.emit()
        return True

    @Slot(str, result=str)
    def getBatchTelemetryJson(self, batch_id: str) -> str:
        data = self.historian.get_batch_telemetry(batch_id)
        return json.dumps(data)

    @Slot(result=str)
    def getBatchesJson(self) -> str:
        return json.dumps(self.historian.list_batches())

    @Slot(result=str)
    def getAuditEventsJson(self) -> str:
        return json.dumps(self.audit_store.list_events())

    @Slot(result=str)
    def verifyAuditChainJson(self) -> str:
        valid, msg = self.audit_store.verify_chain()
        return json.dumps({"valid": valid, "message": msg})

    @Slot(result=str)
    def getActiveAlarmsJson(self) -> str:
        return json.dumps(self.alarm_mgr.list_active())

    @Slot(result=str)
    def getRecipesJson(self) -> str:
        return json.dumps(self.recipe_store.list_recipes())

    @Slot(str, str, str, str, result=str)
    def saveRecipeFromDesigner(self, recipe_id: str, name: str, payload_json: str, target_status: str = "draft") -> str:
        try:
            payload = json.loads(payload_json) if payload_json else {}
            payload["id"] = recipe_id
            payload["name"] = name
            payload["status"] = target_status

            from scada.recipes import serialize_designer_timeline_to_isa88
            from scada.store import scada_db

            recipe = serialize_designer_timeline_to_isa88(payload, self._current_user)

            version_int = 1
            try:
                clean_v = str(recipe.version).lower().replace("v", "").strip()
                version_int = int(float(clean_v)) if clean_v else 1
            except Exception:
                version_int = 1

            self.recipe_store.save_recipe(
                recipe.id, version_int, recipe.name, recipe.to_dict(), self._current_user, recipe.sha256_hash
            )

            try:
                scada_db.create_recipe(recipe.id, recipe.name, recipe.to_dict(), self._current_user, recipe.sha256_hash)
            except Exception:
                try:
                    scada_db.update_recipe(recipe.id, recipe.name, recipe.to_dict(), self._current_user, recipe.sha256_hash)
                except Exception:
                    pass

            self.audit_store.append(
                AuditEvent(
                    timestamp_utc=utc_now(),
                    actor_id=self._current_user,
                    action="RECIPE_SAVED",
                    object_type="RECIPE",
                    object_id=recipe.id,
                    reason=f"Master recipe saved from visual designer ({target_status})",
                    before={},
                    after={
                        "recipe_id": recipe.id,
                        "version": recipe.version,
                        "status": target_status,
                        "sha256": recipe.sha256_hash,
                    },
                    context={"steps": len(recipe.steps), "estimatedDurationSec": recipe.estimated_duration_sec},
                )
            )
            self.auditUpdated.emit()
            self.recipeStateUpdated.emit()
            return json.dumps({
                "success": True,
                "recipeId": recipe.id,
                "version": recipe.version,
                "status": target_status,
                "sha256": recipe.sha256_hash,
                "stepsCount": len(recipe.steps),
                "message": f"Recipe {recipe.id} saved with SHA-256 integrity hash: {recipe.sha256_hash[:16]}..."
            })
        except Exception as e:
            return json.dumps({"success": False, "error": str(e)})

    @Slot(str, result=str)
    def getCortexReviewReportJson(self, batch_id: str) -> str:
        return json.dumps(self.cortex.generate_review_by_exception_report(batch_id))

    @Slot(str, float, float, float, result=str)
    def getCortexYieldPredictionJson(self, recipe_id: str, homo_rpm: float, peak_temp: float, vacuum_mbar: float) -> str:
        return json.dumps(self.cortex.yield_agent.predict_yield(recipe_id, homo_rpm, peak_temp, vacuum_mbar))

    @Slot(int, int, int, result=str)
    def getCortexOeeJson(self, total_runtime_sec: int, active_batch_time_sec: int, dev_count: int) -> str:
        return json.dumps(self.cortex.efficiency_agent.calculate_oee(total_runtime_sec, active_batch_time_sec, dev_count))

    @Slot(str, str, result=str)
    def callCortexMcpToolJson(self, tool_name: str, args_json: str) -> str:
        args = json.loads(args_json) if args_json else {}
        if tool_name == "read_batch_record":
            return json.dumps(self.cortex.mcp.read_batch_record(args.get("batch_id", "")))
        elif tool_name == "get_process_params":
            return json.dumps(self.cortex.mcp.get_process_params(args.get("batch_id", ""), args.get("tag")))
        elif tool_name == "query_equipment":
            return json.dumps(self.cortex.mcp.query_equipment(args.get("device_id", "")))
        elif tool_name == "search_deviations":
            return json.dumps(self.cortex.mcp.search_deviations(args.get("query", "")))
        elif tool_name == "get_material_genealogy":
            return json.dumps(self.cortex.mcp.get_material_genealogy(args.get("batch_id", "")))
        elif tool_name == "log_agent_action":
            return json.dumps(self.cortex.mcp.log_agent_action(args.get("agent_name", ""), args.get("action", ""), args.get("rationale", "")))
        return json.dumps({"error": f"Unknown MCP tool: {tool_name}"})

    @Slot(str)
    def next_recipe_step(self, reason: str) -> None:
        if self._recipe_exec_state.get("status") == "RUNNING":
            cur_step = self._recipe_exec_state.get("currentStep", 1)
            tot_steps = self._recipe_exec_state.get("totalSteps", 1)
            if cur_step < tot_steps:
                next_step = cur_step + 1
                self._recipe_exec_state["currentStep"] = next_step
                self._recipe_exec_state["elapsedSec"] = 0
                self.audit_store.append(
                    AuditEvent(
                        timestamp_utc=utc_now(),
                        actor_id=self._current_user,
                        action="RECIPE_STEP_ADVANCED",
                        object_type="RECIPE_STEP",
                        object_id=str(next_step),
                        reason=reason or "Automatic transition to next phase",
                        before={"step": cur_step},
                        after={"step": next_step},
                        context={"batch_id": self._active_batch_id},
                    )
                )
                self.auditUpdated.emit()
            else:
                self.endBatch(self._active_batch_id or "B1", "completed")
            self.recipeStateUpdated.emit()

    @Slot()
    def cleanup(self) -> None:
        """Gracefully stop background timers and worker threads on application exit."""
        if hasattr(self, "timer") and self.timer.isActive():
            self.timer.stop()
        if hasattr(self, "modbus_worker") and self.modbus_worker.isRunning():
            self.modbus_worker.stop()

