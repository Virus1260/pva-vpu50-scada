"""Automated test suite verifying the 5 Invariant Build Gates for CMake, QRC, and QML."""

import os
import re
import unittest
from pathlib import Path


class TestBuildIntegrity(unittest.TestCase):
    def setUp(self):
        self.root_dir = Path(__file__).resolve().parent.parent
        self.cmake_file = self.root_dir / "PVA_VPU50_SCADAContent" / "CMakeLists.txt"
        self.qds_cmake_file = self.root_dir / "qds.cmake"
        self.qrc_file = self.root_dir / "PVA_VPU50_SCADA.qrc"
        self.content_dir = self.root_dir / "PVA_VPU50_SCADAContent"

    def test_gate1_zero_duplicate_files(self):
        """Gate 1: No duplicate file entries in CMakeLists.txt or qds.cmake."""
        if self.cmake_file.exists():
            text = self.cmake_file.read_text(encoding="utf-8")
            # Extract QML_FILES and RESOURCES entries
            entries = []
            for line in text.splitlines():
                line = line.strip()
                if line.endswith(".qml") or line.endswith(".ui.qml") or line.endswith(".svg") or line.endswith(".png"):
                    entries.append(line)
            duplicates = [e for e in set(entries) if entries.count(e) > 1]
            self.assertEqual(duplicates, [], f"Duplicate entries in CMakeLists.txt: {duplicates}")

        if self.qds_cmake_file.exists():
            text = self.qds_cmake_file.read_text(encoding="utf-8")
            add_subdirs = [line.strip() for line in text.splitlines() if line.strip().startswith("add_subdirectory")]
            duplicates = [e for e in set(add_subdirs) if add_subdirs.count(e) > 1]
            self.assertEqual(duplicates, [], f"Duplicate add_subdirectory in qds.cmake: {duplicates}")

    def test_gate2_zero_scratch_paths(self):
        """Gate 2: No scratch/, tmp/, or ephemeral paths in build configuration files."""
        files_to_check = [self.cmake_file, self.qds_cmake_file, self.qrc_file]
        for f in files_to_check:
            if not f.exists():
                continue
            text = f.read_text(encoding="utf-8")
            for forbidden in ["scratch/", "tmp/", ".temp/", "output_frames/"]:
                self.assertNotIn(
                    forbidden,
                    text,
                    f"Forbidden ephemeral path '{forbidden}' found in {f.name}",
                )

    def test_gate3_strict_declarative_ui_qml(self):
        """Gate 3: No arbitrary functions or String(...) constructors in .ui.qml files."""
        ui_qml_files = list(self.content_dir.rglob("*.ui.qml"))
        self.assertGreater(len(ui_qml_files), 0, "No .ui.qml files found")

        for ui_file in ui_qml_files:
            text = ui_file.read_text(encoding="utf-8")
            # Check for function keyword
            has_func = re.search(r"\bfunction\s+[a-zA-Z0-9_]+\s*\(", text)
            self.assertIsNone(
                has_func,
                f"Forbidden function definition in declarative UI file {ui_file.name}: {has_func.group(0) if has_func else ''}",
            )
            # Check for String constructor call (String(...))
            has_string_ctor = re.search(r"\bString\s*\(", text)
            self.assertIsNone(
                has_string_ctor,
                f"Forbidden String(...) constructor in declarative UI file {ui_file.name}",
            )

    def test_gate4_zero_alias_chaining(self):
        """Gate 4: Aliases in .ui.qml files must point directly to local item ids."""
        ui_qml_files = list(self.content_dir.rglob("*.ui.qml"))
        for ui_file in ui_qml_files:
            text = ui_file.read_text(encoding="utf-8")
            for line in text.splitlines():
                line = line.strip()
                if line.startswith("property alias "):
                    # Format: property alias aliasName: target.prop or target
                    # Must not contain multi-level chaining like a.b.c
                    target = line.split(":")[-1].strip()
                    parts = target.split(".")
                    self.assertLessEqual(
                        len(parts),
                        2,
                        f"Detected illegal alias chaining in {ui_file.name}: '{line}'",
                    )

    def test_gate5_native_cpp_backend_files_exist(self):
        """Gate 5: Native C++ engine and client files must exist in App/."""
        app_dir = self.root_dir / "App"
        required_cpp = [
            app_dir / "main.cpp",
            app_dir / "ScadaEngine.h",
            app_dir / "ScadaEngine.cpp",
            app_dir / "PlcModbusClient.h",
            app_dir / "PlcModbusClient.cpp",
            app_dir / "TagRegistry.h",
            app_dir / "TagRegistry.cpp",
        ]
        for src in required_cpp:
            self.assertTrue(src.exists(), f"Required native C++ source missing: {src.name}")


if __name__ == "__main__":
    unittest.main()
