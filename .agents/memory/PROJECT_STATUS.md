# PVA Systems VPU-50 – Agent Handoff Memory & System Architecture

> **IMPORTANT FOR ANY AI AGENT:** Read this document at the start of every session before modifying any code or project configuration.

---

## 1. Project Identity

| Parameter | Specification |
| :--- | :--- |
| **System Name** | PVA Systems VPU 50 Industrial SCADA System |
| **OEM Standard** | EKATO EPOS SCADA Standards (UNIMIX 50 Batch Mixing Skid) |
| **Framework** | Qt 6 Quick / QML + C++ CMake |
| **Resolution Target** | 1280×720 / 1920×1080 Responsive HMI Touch Panel |
| **PLC Interface** | Delta AS332T-A via OPC UA / Modbus TCP |
| **Database** | SQLite with 21 CFR Part 11 Electronic Batch Record & Snapshot Isolation |
| **Workspace** | `C:\Users\Shekhar\Desktop\QT DESIGNER PROJECTS\PVA_VPU50_SCADA` |

---

## 2. Screen Architecture Map

| Screen File | Name | Description | Access Level |
| :--- | :--- | :--- | :--- |
| `Screen_1_Control.ui.qml` | Control Dashboard | 6-Row Tabular Process Overview (Agitator, Homogenizer, External Line, Vacuum, Suction, Heating) | All (Level 1+) |
| `Screen_2_P_ID.qml` | P&ID Schematic | Interactive P&ID with vessel heads, jackets, valve flow animations, PARAVISC rotation, and Floating Recipe Live HUD | All (Level 1+) |
| `Screen_3_Trends.qml` | Process Trends | Multi-channel real-time and historical telemetry chart recorder | All (Level 1+) |
| `Screen_4_Alarms.qml` | Alarms & Events | ISA-18.2 compliant alarm list with priority badges, timestamping, and mandatory comment ACK handling | All (Level 1+) |
| `Screen_5_Recipes.qml` | Recipe Execution | ISA-88 batch execution monitor, dual step/batch timers, concurrent sub-op progress bars, and 21 CFR hold point confirmation | All (Level 1+) |
| `Screen_9_RecipeMaker.qml`| Recipe Maker | Human-flow master recipe authoring: Stages → Tasks → Inspector, BOM/formulation, interlocks, governance (Incharge+) | Incharge & Admin (Level 2+) |
| `Screen_6_Audit.qml` | Audit Trail | 21 CFR Part 11 electronic batch record with operator e-signatures and cryptographic SHA-256 chain | All (Level 1+) |
| `Screen_7_Playback.qml` | Process Playback | Historical batch replay with scrubber and variable playback speed | All (Level 1+) |
| `Screen_8_Diagnostics.qml`| Maintenance & I/O | Hardware I/O testing, sensor calibration, and manual PLC override | Incharge & Admin (Level 2+) |

---

## 3. Modal Architecture

- **`NumericKeypadModal.qml`**: 4×4 Touch Keypad with `Del`, `Esc`, `Clear`, `−`, and `OK`.
- **`ConfirmationModal.qml`**: 5-column Valve Status Matrix and mandatory safety interlock for manual butterfly valves.
- **`PlantModeModal.qml`**: Plant-level Automatic `(A)` vs Manual `(M)` mode toggle and recipe routing.
- **`AgitatorModeModal.qml`**: CCW, CW, and Reversing agitation modes.
- **`HomogenizerModeModal.qml`**: Permanent and Interval homogenization modes.
- **`VacuumModeModal.qml`**: Continuous, Vacuum Level Setpoint, and Material Loading modes.
- **`ExternalLineModeModal.qml`**: Product Discharge, Recirculation Loop, CIP Rinse, CIP Discharge, CIP Drying.
- **`FillingModeModal.qml`**: Liquid Port, Solids Funnel, and Bottom Suction charging.
- **`HeatingModeModal.qml`**: Heating/Cooling, Jacket/Product regulation, Baffle/Homogenizer temperature source.

---

## 4. Equipment Tag Reference (VPU 50)

### Manufacturing Vessel (1B1001)
- `1M1501`: Helical Anchor Stirrer Motor (Speed in RPM)
- `1X1001` / `1M2003`: Bottom Rotor-Stator Homogenizer Motor (Speed in RPM, ramp support)
- `1M2001`: Discharge Centrifugal Pump Motor & Drain Valve Path
- `1M4001`: Vessel Lid Hydraulic Lift
- `1M5001` / `1P5001`: Liquid Ring Vacuum Pump Motor
- `1M6001`: Recirculation Loop Pump Motor
- `1E6001`: Jacket Electric Heating Element & Cooling Circuit
- `1K1001`: CIP & Raw Material Charging Port Valve
- `1T1001`: Product Temperature Transmitter (°C)
- `1P1001`: Vessel Pressure Transmitter (mbar)

---

## 5. Recipe Architecture & 21 CFR Part 11 Persistence

- **Database Engine**: SQLite via `scada/store.py` (`ScadaDatabaseStore`).
- **Tables**: `users`, `recipes`, `recipe_audit_log`, `batch_runs`, `batch_events`, `samples`.
- **Snapshot Isolation Rule**:
  - Master recipes in `recipes` are editable only by Incharge/Admin.
  - When **Execute** is clicked, the active approved recipe is copied into `batch_runs.recipe_snapshot_json`.
  - The live `RecipeExecutionEngine` executes exclusively against the immutable `batch_runs` snapshot, guaranteeing that future edits to master recipes never corrupt historical or running batch records.

### Recipe Maker UI (2026-08-23)
- Rebuilt as modular widgets under `components/widgets/Screen_9_RecipeMaker/` (same pattern as Control / P&ID).
- Operator flow matches MES authoring (Leucine/SAP): **name stages on the left, detail tasks on the right, edit the selected task in the inspector**.
- Tabs: Tasks, Parameters, Bill of Materials, Interlocks, Governance. Collaborators overlay for Author / Reviewer / Approver.
- Seeded with Industrial Shampoo on vessel `1B1001` using real P&ID tags (`1M1501`, `1X1001`, `1M5001`, `1E6001`, `1K1001`, `1M2001`).
- Recipe Execution remains `Screen_5_Recipes` (operator). SQLite snapshot rule is unchanged; this pass is authoring UX, not a second persistence layer.
