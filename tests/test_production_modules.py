"""Unit tests verifying Recipe Persistence with SHA-256, Screen 1 Manual Lockout, and Delta Modbus Mapping."""

import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import MagicMock

from scada.controller import ScadaController
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
    # 1. PROCESS CONTROL & 21 CFR PART 11 AUDIT INTEGRITY
    # =========================================================================
    def test_process_setpoint_and_audit_logging(self):
        # 1. Set valid agitator speed
        ok = self.controller.setProcessSetpoint("vpu.main.agitator_speed", 35.0, "Production mixing phase")
        self.assertTrue(ok)
        self.assertEqual(self.controller._telemetry.get("vpu.main.agitator_speed"), 35.0)

        # 2. Verify audit trail recorded with cryptographic hash
        audit_events = self.controller.audit_store.list_events()
        set_events = [e for e in audit_events if e["action"] == "SETPOINT_MODIFIED"]
        self.assertGreaterEqual(len(set_events), 1)
        self.assertEqual(set_events[-1]["object_id"], "vpu.main.agitator_speed")
        self.assertEqual(set_events[-1]["after"]["value"], 35.0)

        # 3. Verify cryptographic chain
        valid, msg = self.controller.audit_store.verify_chain()
        self.assertTrue(valid)

    # =========================================================================
    # 2. BATCH LIFECYCLE & HISTORIAN PERSISTENCE
    # =========================================================================
    def test_batch_lifecycle_and_historian(self):
        batch_id = self.controller.startBatch("Validation Mixing Run")
        self.assertEqual(self.controller.activeBatchId, batch_id)

        # Confirm batch started audit event
        audit_events = self.controller.audit_store.list_events()
        start_events = [e for e in audit_events if e["action"] == "BATCH_STARTED"]
        self.assertGreaterEqual(len(start_events), 1)

        # End batch
        ok = self.controller.endBatch(batch_id, "completed")
        self.assertTrue(ok)
        self.assertEqual(self.controller.activeBatchId, "")

        # Confirm batches list contains it
        batches_json = self.controller.getBatchesJson()
        batches = json.loads(batches_json)
        found = [b for b in batches if b["id"] == batch_id]
        self.assertEqual(len(found), 1)
        self.assertEqual(found[0]["status"], "completed")

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

    # =========================================================================
    # 4. OPERATIONAL MODES, READ-ONLY LOCK & SIMULATION OVERWRITE PREVENTION
    # =========================================================================
    def test_bench_monitor_read_only_protection(self):
        monitor_controller = ScadaController(self.runtime_dir, mode="BENCH_MONITOR")
        monitor_controller.loginUser("supervisor", "supervisor")

        try:
            # 1. Parameter write must be rejected with PermissionError
            with self.assertRaises(PermissionError) as ctx:
                monitor_controller.setProcessSetpoint("vpu.main.agitator_speed", 30.0, "Test write")
            self.assertIn("READ_ONLY_LOCK", str(ctx.exception))

            # 2. Worker step download must be rejected
            res = monitor_controller.modbus_worker.download_step({}, step_index=1)
            self.assertFalse(res["verified"])
            self.assertIn("READ_ONLY_LOCK", res["error"])

            # 3. Worker setpoint write must be rejected
            res_sp = monitor_controller.modbus_worker.write_process_setpoint(0, 30)
            self.assertFalse(res_sp["success"])
            self.assertIn("READ_ONLY_LOCK", res_sp["error"])
        finally:
            monitor_controller.cleanup()

    def test_bench_monitor_does_not_overwrite_physical_telemetry_on_tick(self):
        monitor_controller = ScadaController(self.runtime_dir, mode="BENCH_MONITOR")
        try:
            # 1. Simulate arrival of real Modbus RTD telemetry (e.g. 24.8 °C)
            monitor_controller._on_modbus_telemetry({
                "vpu.main.temperature": 24.8,
                "vpu.jacket.temperature": 25.1,
                "vpu.main.agitator_speed": 0.0,
            })
            self.assertEqual(monitor_controller.telemetry.get("vpu.main.temperature"), 24.8)

            # 2. Trigger 500ms controller tick
            monitor_controller._on_tick()

            # 3. Telemetry must STILL be 24.8 °C (must NOT be overwritten by simulator!)
            self.assertEqual(monitor_controller.telemetry.get("vpu.main.temperature"), 24.8)
            self.assertEqual(monitor_controller.telemetry.get("vpu.jacket.temperature"), 25.1)
        finally:
            monitor_controller.cleanup()

    def test_offline_command_rejection_no_false_success(self):
        control_controller = ScadaController(self.runtime_dir, mode="BENCH_CONTROL")
        try:
            # Worker is offline (no PLC at 192.168.1.5 connected)
            res = control_controller.modbus_worker.download_step({}, step_index=1)
            self.assertFalse(res["verified"])
            self.assertIn("HARDWARE_DISCONNECTED", res["error"])

            res_sp = control_controller.modbus_worker.write_process_setpoint(0, 45)
            self.assertFalse(res_sp["success"])
            self.assertIn("HARDWARE_DISCONNECTED", res_sp["error"])
        finally:
            control_controller.cleanup()

    def test_digital_output_control_and_readback(self):
        # 1. Test in SIMULATION mode
        sim_controller = ScadaController(self.runtime_dir, mode="SIMULATION")
        try:
            res_json = sim_controller.setDigitalOutput(2, True, force=False)
            res = json.loads(res_json)
            self.assertTrue(res["success"])
            self.assertEqual(res["output"], 2)
            self.assertTrue(res["state"])

            io_status = json.loads(sim_controller.getDigitalIoStatusJson())
            self.assertIn("outputs", io_status)
            self.assertIn("inputs", io_status)
        finally:
            sim_controller.cleanup()

        # 2. Test in BENCH_MONITOR mode with read-only protection
        monitor_controller = ScadaController(self.runtime_dir, mode="BENCH_MONITOR")
        try:
            # Non-forced write must be rejected
            res_locked = monitor_controller.modbus_worker.write_digital_output(2, True, force=False)
            self.assertFalse(res_locked["success"])
            self.assertIn("READ_ONLY_LOCK", res_locked["error"])
        finally:
            monitor_controller.cleanup()


if __name__ == "__main__":
    unittest.main()
