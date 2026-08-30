"""PVA Systems VPU-50 SCADA Desktop Launcher.

Bridges Python 21 CFR Part 11 / GAMP 5 compliance engine, tag catalogue, and
physics simulation with Qt Quick / QML SCADA interface.
"""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import sys

from PySide6.QtCore import QTimer, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

from scada.controller import ScadaController


PROJECT_ROOT = Path(__file__).resolve().parent


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run the PVA VPU-50 SCADA desktop client.")
    parser.add_argument(
        "--verify-qml",
        action="store_true",
        help="Load QML offscreen, then exit. Used by the automated verification test.",
    )
    parser.add_argument(
        "--runtime-dir",
        type=Path,
        default=PROJECT_ROOT / "runtime",
        help="Runtime simulation data directory for SQLite stores.",
    )
    return parser.parse_args()


def main() -> int:
    arguments = parse_arguments()
    if arguments.verify_qml:
        os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
    QQuickStyle.setStyle("Basic")
    app = QGuiApplication(sys.argv[:1])
    app.setOrganizationName("PVASystems")
    app.setApplicationName("PVA VPU-50 Industrial SCADA")

    controller = ScadaController(arguments.runtime_dir)
    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("Scada", controller)
    
    # Add import paths
    content_dir = PROJECT_ROOT / "PVA_VPU50_SCADAContent"
    engine.addImportPath(str(PROJECT_ROOT))
    engine.addImportPath(str(content_dir))

    qml_path = content_dir / "App.qml"
    engine.load(QUrl.fromLocalFile(str(qml_path)))
    if not engine.rootObjects():
        return 1
    if arguments.verify_qml:
        QTimer.singleShot(500, app.quit)
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
