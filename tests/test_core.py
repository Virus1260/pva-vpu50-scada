"""Automated test suite verifying 21 CFR Part 11 and GAMP 5 compliance requirements."""

import json
from pathlib import Path
import tempfile
import unittest

from scada.audit import AuditEvent, AuditStore, utc_now
from scada.configuration import ConfigurationRegistry
from scada.security import SecurityManager
from scada.alarms import AlarmManager
from scada.store import HistorianStore, RecipeStore


class TestScadaCompliance(unittest.TestCase):
    def setUp(self):
        self.td = tempfile.TemporaryDirectory()
        self.temp_dir = Path(self.td.name)
        self.config_dir = Path(__file__).resolve().parent.parent / "scada" / "config"
        self.registry = ConfigurationRegistry(self.config_dir)

    def tearDown(self):
        self.td.cleanup()

    def test_audit_trail_cryptographic_chain(self):
        audit_store = AuditStore(self.temp_dir / "audit.db", b"TEST_KEY_32_BYTES_REQUIRED_123456")
        
        # 1. Append 3 valid events
        audit_store.append(AuditEvent(utc_now(), "operator_1", "LOGIN", "SESSION", "S1", "Logon", {}, {}, {}))
        audit_store.append(AuditEvent(utc_now(), "operator_1", "SETPOINT", "TAG", "PIC101", "Adjust vacuum", {"sp": 0}, {"sp": -400}, {}))
        audit_store.append(AuditEvent(utc_now(), "operator_1", "START", "RECIPE", "R1", "Batch Start", {}, {}, {}))
        
        valid, msg = audit_store.verify_chain()
        self.assertTrue(valid)
        self.assertIn("Verified 3 cryptographically linked", msg)

    def test_tag_catalog_range_validation(self):
        # Test valid speed
        valid, _ = self.registry.validate_value("vpu.main.agitator_speed", 45.0)
        self.assertTrue(valid)
        
        # Test out of bounds speed (>60 rpm)
        invalid, msg = self.registry.validate_value("vpu.main.agitator_speed", 120.0)
        self.assertFalse(invalid)
        self.assertIn("out of range", msg)

    def test_rbac_security_enforcement(self):
        security = SecurityManager(self.registry)
        
        # Operator can read telemetry and acknowledge alarms
        self.assertTrue(security.check_permission("operator", "telemetry.read"))
        self.assertTrue(security.check_permission("operator", "alarm.acknowledge"))
        
        # Operator CANNOT approve recipes (requires QA or Admin)
        self.assertFalse(security.check_permission("operator", "recipe.approve"))
        
        # QA CAN approve recipes
        self.assertTrue(security.check_permission("quality", "recipe.approve"))

    def test_alarm_acknowledgement_requires_comment(self):
        audit_store = AuditStore(self.temp_dir / "audit.db", b"TEST_KEY_32_BYTES_REQUIRED_123456")
        alarm_mgr = AlarmManager(self.registry, audit_store)
        
        # Trigger high temp alarm
        alarm_mgr.evaluate_telemetry({"vpu.main.temperature": 115.0})
        active = alarm_mgr.list_active()
        self.assertGreater(len(active), 0)
        alm_id = active[0]["id"]
        
        # Attempt acknowledge with empty comment -> must raise ValueError per 21 CFR Part 11
        with self.assertRaises(ValueError):
            alarm_mgr.acknowledge_alarm(alm_id, "operator_1", "")
            
        # Acknowledge with valid reason
        alarm_mgr.acknowledge_alarm(alm_id, "operator_1", "Temperature cooling valve opened manually")

    def test_recipe_catalog_schema_validation(self):
        from scada.recipes import RecipeCatalog, DeviceType, StopConditionType
        catalog = RecipeCatalog()
        recipes = catalog.list_recipes()
        self.assertGreaterEqual(len(recipes), 2, "Catalog must contain at least 2 default recipe templates")

        shampoo = catalog.get_recipe("REC-VPU50-001")
        self.assertIsNotNone(shampoo, "Industrial Shampoo recipe must exist in catalog")
        self.assertEqual(shampoo.name, "Industrial Shampoo Formulation")
        self.assertEqual(len(shampoo.ingredients), 15, "Shampoo BOM must have 15 ingredients")
        self.assertEqual(len(shampoo.steps), 10, "Shampoo recipe must have 10 nested parent steps")

        # Verify nested sub-step operations
        step_1 = shampoo.steps[0]
        self.assertEqual(len(step_1.operations), 1)
        self.assertEqual(step_1.operations[0].device, DeviceType.FILL_VALVE)

        step_7 = shampoo.steps[6]
        self.assertEqual(len(step_7.operations), 5, "Phase C must have 5 concurrent operations")
        devices = [op.device for op in step_7.operations]
        self.assertIn(DeviceType.HOMOGENIZER, devices)
        self.assertIn(DeviceType.AGITATOR, devices)
        self.assertIn(DeviceType.VACUUM, devices)

    def test_recipe_execution_state_transitions(self):
        from scada.recipes import RecipeCatalog, RecipeExecutionEngine
        catalog = RecipeCatalog()
        shampoo = catalog.get_recipe("REC-VPU50-001")
        self.assertIsNotNone(shampoo)

        engine = RecipeExecutionEngine(shampoo)
        self.assertFalse(engine.is_running)

        # Start execution
        started = engine.start()
        self.assertTrue(started)
        self.assertTrue(engine.is_running)
        self.assertEqual(engine.current_step_index, 0)

        # Step 1 tick for 185 seconds (duration is 180s)
        engine.tick(185.0)
        # Should transition to Step 2
        self.assertEqual(engine.current_step_index, 1)

        # Step 2 tick for 245 seconds (duration is 240s)
        engine.tick(245.0)
        # Step 3 requires confirmation
        self.assertEqual(engine.current_step_index, 2)
        self.assertTrue(engine.confirm_active, "Step 3 must trigger 21 CFR hold point confirmation")
        self.assertTrue(engine.manual_waiting)

        # Confirm hold point
        confirmed = engine.confirm_hold_point("operator_1")
        self.assertTrue(confirmed)
        self.assertFalse(engine.confirm_active)

        # Snapshot check
        snap = engine.get_execution_snapshot()
        self.assertTrue(snap["recipeLoaded"])
        self.assertEqual(snap["currentStepIndex"], 2)
        self.assertGreater(len(snap["operations"]), 0)
        self.assertIn("ingredients", snap)
        self.assertGreater(len(snap["ingredients"]), 0)

    def test_recipe_step_mutations_and_cosmetic_gel(self):
        from scada.recipes import RecipeCatalog, RecipeExecutionEngine
        catalog = RecipeCatalog()
        gel = catalog.get_recipe("REC-VPU50-003")
        self.assertIsNotNone(gel, "High-Shear Cosmetic Gel must exist in catalog")
        self.assertEqual(len(gel.steps), 4)
        self.assertEqual(len(gel.ingredients), 8)

        engine = RecipeExecutionEngine(gel)
        initial_first_step_id = engine.recipe.steps[0].id

        # Move step down
        moved = engine.move_step(initial_first_step_id, 1)
        self.assertTrue(moved)
        self.assertEqual(engine.recipe.steps[1].id, initial_first_step_id)

        # Move step back up
        moved_up = engine.move_step(initial_first_step_id, -1)
        self.assertTrue(moved_up)
        self.assertEqual(engine.recipe.steps[0].id, initial_first_step_id)

        # Add new step
        new_step = engine.add_step("Phase Z: QC Testing", "Analytical viscosity check")
        self.assertIsNotNone(new_step)
        self.assertEqual(len(engine.recipe.steps), 5)

        # Remove step
        removed = engine.remove_step(new_step.id)
        self.assertTrue(removed)
        self.assertEqual(len(engine.recipe.steps), 4)

    def test_sqlite_persistence_and_snapshot_isolation(self):
        import tempfile
        from pathlib import Path
        from scada.store import ScadaDatabaseStore

        with tempfile.TemporaryDirectory() as tmp_dir:
            db_path = Path(tmp_dir) / "test_scada.db"
            store = ScadaDatabaseStore(db_path)
            store.initialise()

            # 1. Verify default users seeded
            with store.connection() as conn:
                users = conn.execute("SELECT username, role FROM users").fetchall()
                roles = {u["username"]: u["role"] for u in users}
                self.assertEqual(roles.get("operator"), "operator")
                self.assertEqual(roles.get("incharge"), "incharge")
                self.assertEqual(roles.get("admin"), "administrator")

            # 2. Create Master Recipe
            test_body = {
                "id": "REC-TEST-001",
                "name": "Test Hydrogel",
                "version": "1.0",
                "author": "Incharge",
                "approvalStatus": "APPROVED",
                "createdAt": "2026-02-22T00:00:00Z",
                "estimatedDurationSec": 600,
                "batchSizeKg": 25.0,
                "steps": [
                    {"id": 1, "name": "Step 1", "description": "Original Step", "operations": []}
                ],
                "ingredients": []
            }
            store.create_recipe("REC-TEST-001", "Test Hydrogel", test_body, "incharge")
            store.approve_recipe("REC-TEST-001", "Dr. Vance")

            # 3. Start Batch Run -> Creates Immutable Snapshot
            batch_run = store.start_batch_run("REC-TEST-001", "operator_1")
            self.assertIsNotNone(batch_run["batchId"])
            self.assertEqual(batch_run["snapshot"]["name"], "Test Hydrogel")
            self.assertEqual(batch_run["snapshot"]["steps"][0]["name"], "Step 1")

            # 4. Modify Master Recipe (Draft v2)
            updated_body = dict(test_body)
            updated_body["steps"] = [{"id": 1, "name": "Step 1 Modified", "description": "New SOP", "operations": []}]
            store.update_recipe("REC-TEST-001", "Test Hydrogel (Modified)", updated_body, "incharge")

            # 5. Verify Snapshot Isolation: Batch run still holds original Step 1
            events = store.get_batch_events(batch_run["batchId"])
            self.assertGreaterEqual(len(events), 1)
            self.assertEqual(events[0]["eventType"], "batch_start")

            with store.connection() as conn:
                run_row = conn.execute("SELECT recipe_snapshot_json FROM batch_runs WHERE id = ?", (batch_run["batchId"],)).fetchone()
                import json
                snap = json.loads(run_row["recipe_snapshot_json"])
                self.assertEqual(snap["steps"][0]["name"], "Step 1", "Batch run snapshot must NEVER change after master recipe edit")

    def test_pid_device_tags_mapping(self):
        from scada.recipes import DeviceType, PID_TAG_MAP
        self.assertIn("1M1501", PID_TAG_MAP[DeviceType.AGITATOR])
        self.assertIn("1X1001", PID_TAG_MAP[DeviceType.HOMOGENIZER])
        self.assertIn("1M5001", PID_TAG_MAP[DeviceType.VACUUM])
        self.assertIn("1E6001", PID_TAG_MAP[DeviceType.HEATER])
        self.assertIn("1K1001", PID_TAG_MAP[DeviceType.FILL_VALVE])
        self.assertIn("1M2001", PID_TAG_MAP[DeviceType.DRAIN_VALVE])

    def test_cmake_and_qrc_build_integrity(self):
        root_dir = Path(__file__).resolve().parent.parent
        cmake_file = root_dir / "PVA_VPU50_SCADAContent" / "CMakeLists.txt"
        qrc_file = root_dir / "PVA_VPU50_SCADA.qrc"
        qds_cmake = root_dir / "qds.cmake"

        # 1. Check CMakeLists.txt for duplicates
        if cmake_file.exists():
            text = cmake_file.read_text(encoding="utf-8")
            import re
            qml_files = re.findall(r'"([^"]+\.qml|[^"]+\.ui\.qml)"', text)
            duplicates = [f for f in set(qml_files) if qml_files.count(f) > 1]
            self.assertEqual(len(duplicates), 0, f"Found duplicate QML files in CMakeLists.txt: {duplicates}")

        # 2. Check PVA_VPU50_SCADA.qrc for duplicates and non-existent files
        if qrc_file.exists():
            text = qrc_file.read_text(encoding="utf-8")
            import re
            files = re.findall(r'<file>([^<]+)</file>', text)
            duplicates = [f for f in set(files) if files.count(f) > 1]
            self.assertEqual(len(duplicates), 0, f"Found duplicate files in PVA_VPU50_SCADA.qrc: {duplicates}")
            for f in files:
                full_path = root_dir / f
                self.assertTrue(full_path.exists(), f"File in QRC does not exist on disk: {f}")
                self.assertFalse(f.startswith("scratch/"), f"Scratch file found in QRC: {f}")

        # 3. Check qds.cmake for scratch files
        if qds_cmake.exists():
            text = qds_cmake.read_text(encoding="utf-8")
            self.assertNotIn("scratch/", text, "qds.cmake must not contain scratch/ files")


if __name__ == "__main__":
    unittest.main()


