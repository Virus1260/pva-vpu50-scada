# PVA Systems SCADA – Icon Management & Zero-Unicode-Emoji Invariant

## 1. Zero Raw Unicode Emojis In UI (Strict Rule)
- **NEVER** use raw Unicode emojis or symbols (`🔐`, `🔒`, `📦`, `🧼`, `👤`, `⏱`, `✋`, `⧉`, `⚙`, `🔍`, `⏪`, `⏩`, `✕`, `✓`, `➔`) in any `.qml`, `.ui.qml`, or user-facing text strings.
- **Rationale**: On many industrial Linux panels, Windows LTSC builds, and embedded displays lacking full color emoji fonts, Unicode emojis render as empty / broken tofu boxes (`▯`).
- **Standard**: Always use clean, uppercase/title-case ASCII text and render iconography using dedicated vector SVG assets via [`ScadaIcon.qml`](file:///C:/Users/Shekhar/Desktop/QT%20DESIGNER%20PROJECTS/PVA_VPU50_SCADA/PVA_VPU50_SCADAContent/components/widgets/ScadaIcon.qml).

---

## 2. Categorical Icon Repository Architecture
All visual iconography must reside in categorized subdirectories under `PVA_VPU50_SCADAContent/assets/icons/`:

```
PVA_VPU50_SCADAContent/assets/icons/
├── common/        # Universal status badges (icon_check.svg, icon_warning.svg)
├── controls/      # Action buttons & symbols (start, pause, stop, clock, close_x, act_hold, arrow_up, arrow_down, duplicate, act_manual, act_media, act_loop, act_schedule, act_equip)
├── equipment/     # Process machine visual vectors
├── header/        # Header bar icons (user.svg, alarm_bell.svg, alarm_bell_green.svg, lightbulb.svg, favicon.svg)
├── modes/         # Subsystem mode selector tiles (agitator/, homogenizer/, heating/, plant/, suction/, ext/)
├── nav/           # Right sidebar navigation dock icons (status_stack.svg, pid_vessel.svg, trends_chart.svg, alarms_bell.svg, recipes_checklist.svg, recipe_maker.svg, docs_report.svg, logs_order.svg, tools_maintenance.svg)
└── pid/           # P&ID dynamic diagram elements
```

---

## 3. Physical Keyboard & Touchscreen Dual Ergonomics
- All keypad and authentication modals (`LoginModal.qml`, `NumericKeypadModal.qml`, `ConfirmationModal.qml`) must support **dual input**:
  1. **Touchscreen**: Large on-screen keypad buttons with generous finger touch targets (minimum 36px–48px).
  2. **Physical PC Keyboard**: Active keyboard focus capturing digits (`0`-`9`), Enter/Return (`Qt.Key_Return`, `Qt.Key_Enter`), Backspace (`Qt.Key_Backspace`), Escape (`Qt.Key_Escape`), and Delete (`Qt.Key_Delete`).

---

## 4. RBAC Security & Navigation Non-Bypass Invariant
- If an unauthenticated user attempts to navigate to a protected screen (e.g. Diagnostics / Hardware Overrides requiring Level 4+ Maintenance or Level 5 Admin), closing or canceling the `LoginModal` must **immediately revert navigation** to the last authorized screen.
- The user must **NEVER** be left on a restricted screen upon dismissing the authentication prompt.
