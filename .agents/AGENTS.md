# PVA Systems VPU-50 Industrial SCADA – Agent Directives & Rules

## 1. Core Engineering, Build Integrity & Safety Rules
1. **Strict Git Rule**: NEVER run `git commit` or `git push` automatically without explicit user permission.
2. **Continuous CMake, QRC & QML Build Integrity**:
   - On **EVERY** prompt/task, before completing code modifications, always enforce the 5 Invariant Build Gates (see `.agents/rules/cmake_qrc_build_integrity.md`):
     1. **Zero Duplicate Entries**: No duplicate files in `CMakeLists.txt`, `PVA_VPU50_SCADA.qrc`, or `qds.cmake` (prevents C++ `redefinition of 'unit'` error).
     2. **Zero Scratch Paths**: No `scratch/`, `tmp/`, or ephemeral paths in `qds.cmake`, `PVA_VPU50_SCADA.qrc`, or `CMakeLists.txt`.
     3. **Strict Qt Design Studio Declarative Rule**: No arbitrary functions or constructor calls (`String(...)`) in `.ui.qml` files (prevents error `M222`).
     4. **Zero Alias Chaining**: Direct item aliases only in `.ui.qml` (prevents `Invalid alias target location`).
     5. **Mandatory Automated Test Verification**: Always run `python -m unittest discover tests` on every single change.
3. **Process Running Safety Interlock**:
   - While any equipment row is actively running (`isPlaying == true`), its speed setpoint, steppers (`+`/`−`), and mode selector modal MUST be locked.
   - Attempting parameter edits while running must trigger an annunciator alert: `"SAFETY INTERLOCK: Stop [Equipment] before modifying mode or setpoint parameters."`
4. **Mandatory Valve Confirmation Interlock**:
   - External Line Recirculation, CIP modes, and Suction charging modes MUST trigger `ConfirmationModal` with the 5-column Valve Status Matrix.
   - The `CONFIRM POSITIONING` button unlocks ONLY after all required manual butterfly valves (`V301`, `V302`, `V303`) are checked by the operator.
6. **Zero Raw Unicode Emojis & Strict SVG Iconography**:
   - NEVER use raw Unicode emojis (`🔒`, `🔐`, `📦`, `🧼`, `👤`, `⏱`, etc.) in QML text (prevents tofu `▯` boxes on industrial Linux/Windows displays).
   - Use categorical SVG icons from `assets/icons/` via `ScadaIcon.qml`. (See `.agents/rules/no_unicode_emojis_and_icon_management.md`).
7. **Physical Keyboard & RBAC Navigation Security**:
   - All interactive modals must support physical PC keyboard entry (`0`-`9`, Enter, Backspace, Esc).
   - Dismissing authentication on restricted screens (e.g. Diagnostics) MUST revert navigation to the previously authorized screen.

---

## 2. Visual Design Language
- **Background**: `#08213b` / Deep Industrial Navy
- **Cards & Compartments**: `#0a2e50` / `#0c345a` / `#154d80`
- **Borders & Dividers**: `#1d5b94` / `#1e40af`
- **Active Green**: `#78dc20` / `#22c55e`
- **Active Cyan Needles**: `#00d2ff` / `#38bdf8`
- **Alarm / Fault Red**: `#ff4444` / `#dc2626`
- **Warning Amber**: `#f59e0b` / `#f5d033`
- **OEM Identity**: PVA Systems (Machine Model: **VPU 50** Batch Mixing Skid).
