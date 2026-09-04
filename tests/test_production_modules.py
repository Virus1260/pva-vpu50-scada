"""Unit tests verifying Recipe Persistence with SHA-256, Screen 1 Manual Lockout, and Delta Modbus Mapping."""

import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import MagicMock

from scada.controller import ScadaController
from scada.recipes import (
    Recipe,
    calculate_recipe_hash,
    serialize_designer_timeline_to_isa88,
)
from scada.modbus.delta_map import (
    DeltaRegisterMap,
    pack_step_setpoints,
    unpack_telemetry_registers,
    to_signed_16,
    to_unsigned_16,
)
from scada.modbus.handshake import Isa88BatchHandshake, ReadBackVerificationError


class TestProductionModules(unittest.TestCase):
    def setUp(self):
        self.td = tempfile.TemporaryDirectory()
        self.runtime_dir = Path(self.td.name)
        self.controller = ScadaController(self.runtime_dir)
        self.controller.loginUser("supervisor", "supervisor")

    def tearDown(self):
        if hasattr(self.controller, "modbus_worker"):
            self.controller.modbus_worker.stop()
        self.td.cleanup()

    # =========================================================================
    # 1. RECIPE PERSISTENCE & SHA-256 SCHEMA SERIALIZATION
    # =========================================================================
    def test_designer_timeline_serialization_and_sha256(self):
        sample_designer_payload = {
            "id": "REC-VPU50-TEST",
            "name": "Validation Ointment Batch",
            "version": "1.0",
            "status": "DRAFT",
            "batchSizeKg": 100.0,
            "steps": [
                {
                    "stepId": 1,
                    "name": "Phase A Aqueous Charge",
                    "phaseType": "PHASE_AUTO_TRANSFER",
                    "durationMin": 5,
                    "durationSec": 0,
                    "guidanceText": "Auto charge DI water",
                },
                {
                    "stepId": 2,
                    "name": "Thermal Heating to 75C",
                    "phaseType": "PHASE_THERMAL_CONTROL",
                    "targetTemp": 75.0,
                    "agitatorSpeed": 25.0,
                    "durationMin": 10,
                    "durationSec": 0,
                },
                {
                    "stepId": 3,
                    "name": "High-Shear Emulsification",
                    "phaseType": "PHASE_HOMOGENIZATION",
                    "homogenizerSpeed": 2800.0,
                    "runAgitatorCoActive": True,
                    "coActiveAgitatorSpeed": 35.0,
                    "durationMin": 15,
                    "durationSec": 0,
                },
                {
                    "stepId": 4,
                    "name": "Vacuum Deaeration",
                    "phaseType": "PHASE_VACUUM_CONTROL",
                    "targetVacuum": -450.0,
                    "durationMin": 8,
                    "durationSec": 0,
                },
            ],
        }

        # Serialize into ISA-88 standard recipe
        recipe = serialize_designer_timeline_to_isa88(sample_designer_payload, author=self.controller._current_user)

        self.assertIsInstance(recipe, Recipe)
        self.assertEqual(recipe.id, "REC-VPU50-TEST")
        self.assertEqual(len(recipe.steps), 4)
        self.assertEqual(recipe.estimated_duration_sec, (5 + 10 + 15 + 8) * 60)

        # Check operations & PID mapping
        homo_step = recipe.steps[2]
        self.assertEqual(len(homo_step.operations), 2)
        devices = [op.device.value for op in homo_step.operations]
        self.assertIn("homogenizer", devices)
        self.assertIn("agitator", devices)

        # SHA-256 integrity verification
        self.assertTrue(len(recipe.sha256_hash) == 64, "SHA-256 must be 64-char hex string")
        calculated = calculate_recipe_hash(recipe.to_dict())
        self.assertEqual(recipe.sha256_hash, calculated)

        # Test controller slot invocation
        res_json = self.controller.saveRecipeFromDesigner(
            recipe.id, recipe.name, json.dumps(sample_designer_payload), "DRAFT"
        )
        res = json.loads(res_json)
        self.assertTrue(res["success"])
        self.assertEqual(res["sha256"], recipe.sha256_hash)

        # Verify audit trail logging
        audit_events = self.controller.audit_store.list_events()
        saved_events = [e for e in audit_events if e["action"] == "RECIPE_SAVED"]
        self.assertGreaterEqual(len(saved_events), 1)
        self.assertEqual(saved_events[-1]["object_id"], "REC-VPU50-TEST")

    # =========================================================================
    # 2. RUN-MODE DECOUPLING & SCREEN 1 LOCKOUT ENFORCEMENT
    # =========================================================================
    def test_screen_1_lockout_during_active_recipe(self):
        # 1. In IDLE state, manual adjustments are permitted
        self.assertFalse(self.controller.recipeRunning)
        ok = self.controller.setProcessSetpoint("vpu.main.agitator_speed", 30.0, "Manual pre-check")
        self.assertTrue(ok)
        self.assertEqual(self.controller._telemetry.get("vpu.main.agitator_speed"), 30.0)

        # 2. Start an automatic batch
        batch_id = self.controller.startBatch("REC-LOTION-01")
        self.assertTrue(self.controller.recipeRunning)
        self.assertEqual(self.controller.activeBatchId, batch_id)

        # 3. Attempt manual override while recipe is executing -> MUST BE REJECTED
        with self.assertRaises(PermissionError):
            self.controller.setProcessSetpoint("vpu.main.agitator_speed", 45.0, "Operator unauthorized tweak")

        # 4. Confirm security violation was recorded to 21 CFR Part 11 audit log
        audit_events = self.controller.audit_store.list_events()
        violations = [e for e in audit_events if e["action"] == "SECURITY_VIOLATION"]
        self.assertGreaterEqual(len(violations), 1)
        self.assertEqual(violations[-1]["reason"], f"Attempted manual override while recipe active (Batch {batch_id})")

        # 5. End batch -> Lockout must release automatically
        self.controller.endBatch(batch_id, "completed")
        self.assertFalse(self.controller.recipeRunning)

        # Manual control permitted again
        ok_after = self.controller.setProcessSetpoint("vpu.main.agitator_speed", 35.0, "Post-batch manual wash")
        self.assertTrue(ok_after)

    # =========================================================================
    # 3. DELTA AS332T-A MODBUS MEMORY MAPPING & READ-BACK VERIFICATION
    # =========================================================================
    def test_delta_modbus_packing_and_unpacking(self):
        step_params = {
            "agitatorSpeed": 35.0,
            "homogenizerSpeed": 2800.0,
            "targetTemp": 82.5,
            "tempGradient": 12.0,
            "targetVacuum": -450.0,
            "durationMin": 15,
            "durationSec": 30,
            "agitatorMode": "agitator_cw",
            "homogenizerMode": "homo_permanent",
            "thermalMode": "heat_mode_heating",
            "vacuumMode": "vac_auto_drawdown",
        }

        # 1. Pack into 16-bit holding registers
        packed = pack_step_setpoints(step_params, step_index=4)
        self.assertEqual(packed[DeltaRegisterMap.REG_STEP_AGITATOR_SPEED_SP], 35)
        self.assertEqual(packed[DeltaRegisterMap.REG_STEP_HOMOGENIZER_SPEED_SP], 2800)
        self.assertEqual(packed[DeltaRegisterMap.REG_STEP_TEMP_SP], 825)  # 82.5 * 10
        self.assertEqual(packed[DeltaRegisterMap.REG_STEP_TEMP_RAMP_SP], 120) # 12.0 * 10
        self.assertEqual(to_signed_16(packed[DeltaRegisterMap.REG_STEP_VACUUM_SP]), -4500) # -450.0 * 10
        self.assertEqual(packed[DeltaRegisterMap.REG_STEP_DURATION_SEC_SP], 930) # 15*60 + 30
        self.assertEqual(packed[DeltaRegisterMap.REG_STEP_INDEX], 4)

        # 2. Test Telemetry Unpacking
        raw_regs = [0] * 20
        raw_regs[DeltaRegisterMap.REG_AGITATOR_SPEED_PV] = 35
        raw_regs[DeltaRegisterMap.REG_HOMOGENIZER_SPEED_PV] = 2800
        raw_regs[DeltaRegisterMap.REG_VESSEL_TEMP_PV] = 825
        raw_regs[DeltaRegisterMap.REG_JACKET_TEMP_PV] = 850
        raw_regs[DeltaRegisterMap.REG_VACUUM_PRESSURE_PV] = to_unsigned_16(-4500)
        raw_regs[DeltaRegisterMap.REG_VESSEL_LEVEL_PV] = 2500  # 250.0 L
        raw_regs[DeltaRegisterMap.REG_AGITATOR_CURRENT] = 45   # 4.5 A
        raw_regs[DeltaRegisterMap.REG_HOMOGENIZER_CURRENT] = 120 # 12.0 A

        raw_coils = [False] * 16
        raw_coils[0] = True  # M32: Batch Running
        raw_coils[1] = True  # M33: Step Running
        raw_coils[8] = True  # M40: FS-102 Seal Flush OK
        raw_coils[9] = True  # M41: LSL-101 Min Level OK

        unpacked = unpack_telemetry_registers(raw_regs, raw_coils)
        self.assertEqual(unpacked["vpu.main.agitator_speed"], 35.0)
        self.assertEqual(unpacked["vpu.main.homogenizer_speed"], 2800.0)
        self.assertEqual(unpacked["vpu.main.temperature"], 82.5)
        self.assertEqual(unpacked["vpu.main.vacuum_pressure"], -450.0)
        self.assertEqual(unpacked["vpu.main.level"], 250.0)
        self.assertTrue(unpacked["plc.batch_running"])
        self.assertTrue(unpacked["interlock.seal_flush_fs102"])

    def test_isa88_readback_verification_check(self):
        step_params = {
            "agitatorSpeed": 40.0,
            "homogenizerSpeed": 3000.0,
            "targetTemp": 70.0,
            "tempGradient": 10.0,
            "targetVacuum": 0.0,
            "durationMin": 10,
            "durationSec": 0,
        }
        packed = pack_step_setpoints(step_params, step_index=1)
        expected_regs = [packed[50 + i] for i in range(len(packed))]

        # Scenario A: Successful Read-back Match
        mock_client_good = MagicMock()
        mock_write_res = MagicMock()
        mock_write_res.isError.return_value = False
        mock_client_good.write_registers.return_value = mock_write_res

        mock_read_res = MagicMock()
        mock_read_res.isError.return_value = False
        mock_read_res.registers = list(expected_regs)
        mock_client_good.read_holding_registers.return_value = mock_read_res

        res = Isa88BatchHandshake.download_step_with_readback(mock_client_good, step_params, step_index=1)
        self.assertTrue(res["verified"])
        # Verify M1 and M2 were commanded
        mock_client_good.write_coil.assert_any_call(DeltaRegisterMap.COIL_AUTO_MANUAL_SELECT, True)
        mock_client_good.write_coil.assert_any_call(DeltaRegisterMap.COIL_STEP_START, True)

        # Scenario B: Corrupted Read-back Mismatch (Safety Failure)
        mock_client_corrupt = MagicMock()
        mock_client_corrupt.write_registers.return_value = mock_write_res

        corrupted_regs = list(expected_regs)
        corrupted_regs[1] = 9999  # Corrupt Homogenizer Speed
        mock_corrupt_read_res = MagicMock()
        mock_corrupt_read_res.isError.return_value = False
        mock_corrupt_read_res.registers = corrupted_regs
        mock_client_corrupt.read_holding_registers.return_value = mock_corrupt_read_res

        with self.assertRaises(ReadBackVerificationError):
            Isa88BatchHandshake.download_step_with_readback(mock_client_corrupt, step_params, step_index=1)


if __name__ == "__main__":
    unittest.main()
