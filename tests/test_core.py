"""Automated test suite verifying 21 CFR Part 11 and GAMP 5 compliance requirements."""

import json
from pathlib import Path
import tempfile
import unittest

from scada.audit import AuditEvent, AuditStore, utc_now
from scada.configuration import ConfigurationRegistry
from scada.security import SecurityManager
from scada.alarms import AlarmManager
from scada.store import HistorianStore


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
        
        # Operator cannot reconfigure system parameters
        self.assertFalse(security.check_permission("operator", "system.configure"))
        
        # Admin can reconfigure system
        self.assertTrue(security.check_permission("administrator", "system.configure"))

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

    def test_historian_telemetry_and_lttb_downsampling(self):
        historian = HistorianStore(self.temp_dir / "historian.db")
        historian.initialise()

        batch = historian.start_batch("BATCH-001", "Production Test Batch", 1, "operator_1")
        self.assertIsNotNone(batch["id"])

        # Write sample telemetry points
        for sec in range(10):
            historian.write_samples(batch["id"], {
                "vpu.main.temperature": 25.0 + sec * 2.0,
                "vpu.main.agitator_speed": 45.0,
            })

        telemetry = historian.get_batch_telemetry(batch["id"])
        tags_recorded = {entry["tag"] for entry in telemetry}
        self.assertIn("vpu.main.temperature", tags_recorded)
        self.assertGreaterEqual(len(telemetry), 10)

        historian.end_batch(batch["id"], "completed")

    def test_sqlite_persistence_and_users(self):
        import tempfile
        from pathlib import Path
        from scada.store import ScadaDatabaseStore

        with tempfile.TemporaryDirectory() as tmp_dir:
            db_path = Path(tmp_dir) / "test_scada.db"
            store = ScadaDatabaseStore(db_path)
            store.initialise()

            with store.connection() as conn:
                users = conn.execute("SELECT username, role FROM users").fetchall()
                roles = {u["username"]: u["role"] for u in users}
                self.assertEqual(roles.get("operator"), "operator")
                self.assertEqual(roles.get("incharge"), "incharge")
                self.assertEqual(roles.get("admin"), "administrator")

    def test_pid_device_tags_mapping(self):
        self.assertIsNotNone(self.registry.get_tag("vpu.main.agitator_speed"))
        self.assertIsNotNone(self.registry.get_tag("vpu.main.homogenizer_speed"))
        self.assertIsNotNone(self.registry.get_tag("vpu.main.temperature"))
        self.assertIsNotNone(self.registry.get_tag("vpu.main.vacuum_pressure"))

    def test_cmake_and_qrc_build_integrity(self):
        root_dir = Path(__file__).resolve().parent.parent
        cmake_file = root_dir / "PVA_VPU50_SCADAContent" / "CMakeLists.txt"
        qrc_file = root_dir / "PVA_VPU50_SCADA.qrc"
        qds_cmake = root_dir / "qds.cmake"

        # 1. Check CMakeLists.txt for duplicates and non-existent files
        if cmake_file.exists():
            text = cmake_file.read_text(encoding="utf-8")
            import re
            all_entries = re.findall(r'"([^"]+)"', text)
            # Filter out cmake keywords or URI names
            entries = [e for e in all_entries if e not in ["PVA_VPU50_SCADAContent", "/qt/qml"]]
            duplicates = [f for f in set(entries) if entries.count(f) > 1]
            self.assertEqual(len(duplicates), 0, f"Found duplicate files in CMakeLists.txt: {duplicates}")
            content_dir = root_dir / "PVA_VPU50_SCADAContent"
            for e in entries:
                full_path = content_dir / e
                self.assertTrue(full_path.exists(), f"File in CMakeLists.txt does not exist on disk: {e}")

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

    def test_cortex_agents_and_mcp_tools(self):
        from scada.cortex import CortexEngine, McpToolRegistry

        class MockController:
            pass

        ctrl = MockController()
        cortex = CortexEngine(ctrl)
        ctrl.cortex = cortex

        # 1. Test MCP Tools
        eq = cortex.mcp.query_equipment("1M1501")
        self.assertEqual(eq["type"], "AGITATOR")
        self.assertEqual(eq["calibration_status"], "VALID")

        genealogy = cortex.mcp.get_material_genealogy("BATCH-01")
        self.assertGreaterEqual(len(genealogy), 3)

        log_res = cortex.mcp.log_agent_action("TestAgent", "TEST_ACTION", "Testing reasoning log")
        self.assertEqual(len(log_res["hash"]), 64)

        # 2. Test Compliance Agent Review-by-Exception
        normal_samples = [{"vpu.main.temperature": 75.0, "vpu.main.vacuum_pressure": -420.0}]
        comp_clean = cortex.compliance_agent.analyze_batch_for_exceptions("BATCH-01", normal_samples)
        self.assertTrue(comp_clean["review_by_exception_passed"])

        excursion_samples = [{"vpu.main.temperature": 85.5, "vpu.main.vacuum_pressure": -420.0}]
        comp_excursion = cortex.compliance_agent.analyze_batch_for_exceptions("BATCH-02", excursion_samples)
        self.assertFalse(comp_excursion["review_by_exception_passed"])
        self.assertEqual(comp_excursion["exception_count"], 1)

        # 3. Test Yield Optimization Agent
        yield_res = cortex.yield_agent.predict_yield("REC-01", 3600.0, 76.0, -450.0)
        self.assertGreater(yield_res["predicted_yield_pct"], 98.0)

        # 4. Test Efficiency Agent OEE
        oee_res = cortex.efficiency_agent.calculate_oee(3600, 3400, 0)
        self.assertGreater(oee_res["oee_pct"], 80.0)

    def test_hardware_definitions_and_shared_components(self):
        """Verify HardwareDefinitions.qml single source of truth and shared UI components."""
        root_dir = Path(__file__).resolve().parent.parent
        content_dir = root_dir / "PVA_VPU50_SCADAContent"
        hw_defs_file = content_dir / "config" / "HardwareDefinitions.qml"
        self.assertTrue(hw_defs_file.exists(), "HardwareDefinitions.qml must exist in config/")

        content = hw_defs_file.read_text(encoding="utf-8")
        # Ensure key hardware constraints are defined
        self.assertIn('"minSpeed": 25.0', content)
        self.assertIn('"maxSpeed": 120.0', content)
        self.assertIn('"minSpeed": 600.0', content)
        self.assertIn('"maxSpeed": 4800.0', content)
        self.assertIn('"minPressure": -800.0', content)
        self.assertIn('"maxPressure": 0.0', content)
        self.assertIn('"minTemp": 15.0', content)
        self.assertIn('"maxTemp": 95.0', content)
        self.assertIn('FS-102', content)

        # Verify shared UI components exist
        common_dir = content_dir / "components" / "common"
        expected_components = [
            "DeviceSetpointStepper.qml",
            "SubsystemModeButton.qml",
            "SubsystemModeSelectorModal.qml",
            "SafetyInterlockBadge.qml"
        ]
        for comp in expected_components:
            comp_file = common_dir / comp
            self.assertTrue(comp_file.exists(), f"Shared component {comp} must exist in components/common/")


if __name__ == "__main__":
    unittest.main()


