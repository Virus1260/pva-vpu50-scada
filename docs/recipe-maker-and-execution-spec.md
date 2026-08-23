# Recipe Maker & Recipe Execution — QML/C++ Spec
### (translated from the VPU10-Batch-Reactor-Control Next.js reference, adapted for Qt + SQLite)

This document is the detailed reference. `RECIPE_SCREENS_PROMPT.md` is the short
version to paste into Antigravity — it points here for the details so the chat
prompt itself stays readable.

---

## 0. What's being kept from the Next.js version, and what's changing

**Kept as-is (it's already correct):** the data model shape — a `Recipe` is an
ordered list of `RecipeStep`s, each with 0+ parallel `RecipeOperation`s; the 7
`StopConditionType`s (timer, level_below/above, temp_above/below, manual,
vessel_empty); the confirmation-step pattern (`requireConfirm` +
`confirmMessage` + `confirmTimeout`); the live execution model (per-operation
`status`/`progress`/`remainingSec`); the cross-screen wiring pattern (one
shared execution-state object that the P&ID screen, Controls screen, and
Header bar all read from).

**Changing, deliberately:**
1. **Two separate screens, not one tabbed screen.** Recipe Maker (authoring)
   and Recipe Execution (monitoring) are gated by different access levels —
   see §3.
2. **SQLite instead of localStorage.** See §2.
3. **Device names become real P&ID tags**, not generic labels. See §1.
4. **A recipe and a batch run become two different objects.** Editing a
   recipe after a batch used it must never change what that batch's record
   shows — see §2.3.
5. **Numeric scaling (×10 for °C, ×100 for %) — decide, don't assume.** The
   Next.js version scaled temperature and level to integers, which is a
   common pattern when a PLC exposes those as fixed-point 16-bit registers.
   Before implementing, check whether the Delta AS332T-A tags you'll
   eventually map to are integer or float registers over OPC UA. If float,
   store and display plain decimal values (`80.0`) — don't carry the ×10
   scaling forward for no reason. If integer, keep it. This is a genuine
   open question, not a style preference — confirm rather than guess.

---

## 1. Device list — map to the real P&ID, not generic labels

The Next.js version's 7 devices (`agitator`, `homogenizer`, `vacuum`,
`heater`, `cooler`, `fillValve`, `drainValve`) map to real VPU-50 tags
(from the P&ID — see the project's `.agent/03` or `DATA/P&ID/` if present;
restated here so this document works standalone):

| Generic device | Real tag(s) | Notes |
|---|---|---|
| Agitator | 1M1501 (motor) via 1G1501 (gearbox) driving 1R1501 (helical anchor) | Speed in RPM |
| Homogenizer | 1X1001, driven by 1M2003 | Up to 8000 RPM; supports ramp, same as the Next.js model |
| Vacuum | 1M5001 / 1P5001 | Vacuum pump; assembly group 50 on the tag legend |
| Heater/Cooler | 1E6001 (4kW immersion) + jacket circuit (assembly group 60, Heating/Cooling System) | The Next.js model splits heater/cooler into two devices; confirm whether the real jacket is a single bidirectional thermal loop (one device, heat-or-cool mode) or genuinely two independent actuators before deciding whether to keep them split |
| Fill valve | Relevant CIP/charging valve, e.g. 1K1001 or the applicable N4 charging-funnel path | Confirm exact tag against the P&ID nozzle schedule rather than guessing |
| Drain valve | Discharge path — 1M2001/1P2001 (discharge pump) and associated valve | Same — confirm against the P&ID before hardcoding |

Where the exact real-world valve tag isn't obvious from the P&ID alone, mark
it `// TODO: confirm with Shekhar` rather than picking one that looks
plausible — this is exactly the kind of detail that's easy to get subtly
wrong.

The Premix Vessel (2B1001, its own stirrer 2R1501/2M1501, jacket 2E6001) is a
second, smaller vessel on the same skid — decide whether recipes address one
vessel, both independently, or both together as a single "batch," and say
which, rather than silently picking one.

---

## 2. Data & persistence (SQLite via QtSql)

### 2.1 Why SQLite specifically

Ships with Qt (`QT += sql`, driver `QSQLITE`) — no separate database server to
install on any of the "hundreds of machines" this needs to run on. One file,
identical on Windows and Linux, via
`QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)`.

### 2.2 Schema

```sql
-- Users & roles (local, per-machine — not a full LDAP/AD integration)
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,        -- store a salted hash, never plaintext
    role TEXT NOT NULL CHECK(role IN ('operator','incharge','administrator')),
    created_at TEXT NOT NULL
);

-- Recipes: the authored, editable "master recipe" (ISA-88 sense)
CREATE TABLE recipes (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    version INTEGER NOT NULL DEFAULT 1,
    status TEXT NOT NULL CHECK(status IN ('draft','approved','deprecated')) DEFAULT 'draft',
    body_json TEXT NOT NULL,            -- the full nested Recipe structure (steps + operations + ingredients)
    created_by INTEGER REFERENCES users(id),
    created_at TEXT NOT NULL,
    approved_by INTEGER REFERENCES users(id),
    approved_at TEXT
);

-- Append-only change log for recipes — never UPDATE/DELETE this table
CREATE TABLE recipe_audit_log (
    id INTEGER PRIMARY KEY,
    recipe_id INTEGER NOT NULL REFERENCES recipes(id),
    action TEXT NOT NULL,               -- 'created' | 'edited' | 'approved' | 'deprecated'
    user_id INTEGER REFERENCES users(id),
    timestamp TEXT NOT NULL,
    detail TEXT                          -- free-text or JSON diff summary
);

-- Batch runs: an IMMUTABLE snapshot of the recipe at the moment Execute was pressed
CREATE TABLE batch_runs (
    id INTEGER PRIMARY KEY,
    recipe_id INTEGER NOT NULL REFERENCES recipes(id),
    recipe_version INTEGER NOT NULL,
    recipe_snapshot_json TEXT NOT NULL, -- copy of body_json at execute time — never re-read from `recipes`
    started_by INTEGER REFERENCES users(id),
    started_at TEXT NOT NULL,
    ended_at TEXT,
    status TEXT NOT NULL CHECK(status IN ('running','complete','aborted')) DEFAULT 'running'
);

-- Append-only electronic batch record — never UPDATE/DELETE
CREATE TABLE batch_events (
    id INTEGER PRIMARY KEY,
    batch_run_id INTEGER NOT NULL REFERENCES batch_runs(id),
    timestamp TEXT NOT NULL,
    event_type TEXT NOT NULL,           -- 'step_start' | 'step_complete' | 'confirm' | 'manual_wait' | 'operator_ack' | 'alarm' | ...
    user_id INTEGER REFERENCES users(id),
    detail_json TEXT
);
```

Store the nested step/operation structure as `body_json` (one column) rather
than fully normalizing it into per-operation rows — recipes are read/written
as whole documents, matching how the Next.js version already models them,
and SQLite's JSON functions are available if you ever need to query inside
it. Normalize `batch_events` fully, though — that table is the audit trail
and needs to be queryable by batch, date, and operator for compliance.

### 2.3 The rule that matters most: recipes and batch runs are different objects

When the operator presses **Execute** on the Recipe Execution screen:
1. Read the current `approved` recipe's `body_json`.
2. Insert a new `batch_runs` row with a **copy** of that JSON in
`recipe_snapshot_json`.
3. The execution engine runs against the **snapshot**, never against the live
`recipes` table.

This means an Incharge editing "Body Lotion Formulation" tomorrow can never
retroactively change what batch #4132's record says it ran today. Skipping
this is the single most common mistake in systems like this — worth getting
right from the start rather than retrofitting later.

---

## 3. Access control ("incharge level access")

Three roles (extend whatever login/user-context already shows
"Administrator" in the header, per your existing screens, rather than
building a second auth system):

| Role | Recipe Maker screen | Recipe Execution screen |
|---|---|---|
| Operator | No access | Full access — run, confirm, monitor |
| Incharge / Supervisor | Full access — create, edit, submit for approval | Full access |
| Administrator | Full access + user management | Full access |

Gate this at the screen-navigation level (don't show the nav-rail icon for
Recipe Maker at all to an Operator, rather than showing it and blocking on
click — a control that's visible but forbidden invites confusion about why).

A lightweight approval step (Incharge authors → Incharge or Administrator
approves before `status` flips to `'approved'`) is enough for now — the
Next.js reference didn't need this because it had no roles; this is a
genuine addition, not a translation.

---

## 4. Recipe Maker screen (Incharge-level, authoring)

Direct translation of the Next.js "Recipe Matrix" tab (§5 of your reference
document), in QML terms:

- **Recipe selector + New/Delete**: a `ComboBox` bound to a `RecipeListModel`
  (a `QAbstractListModel` backed by `SELECT id, name, version, status FROM
  recipes`).
- **Step table**: Qt Quick's `TableView` (Qt 6) is the right control for
  resizable, many-row tabular data — closer to what the Next.js
  `ResizableHeader`/step table was doing than trying to fake a table with
  nested `Row`s. If targeting Qt 5, a `ListView` with a fixed-column
  `RowLayout` delegate is the fallback.
- **Expand/collapse per step** revealing the nested operations sub-table:
  bind delegate height to an `expanded` role on the model, animate with
  `Behavior on height`. Qt 6's `TreeView` is worth evaluating if the
  step→operations nesting benefits from native tree semantics — decide based
  on how deep this needs to go (it's only 2 levels, so a simpler
  expand/collapse `ListView` may be entirely sufficient).
- **Per-operation row**: device `ComboBox` (7 options, real tag names per
  §1), action `ComboBox` (`on`/`off`/`ramp` — ramp only enabled for
  homogenizer, exactly as the reference specifies), delay/duration
  `SpinBox`es, a **dynamic value field** that swaps input type by device
  (RPM number / °C number / % number / ramp-from+ramp-to pair) — a `Loader`
  swapping component based on `device` is the clean way to do this in QML,
  matching the reference's conditional rendering exactly.
- **Stop-condition editor**: `ComboBox` with the 7 types + conditional
  threshold field, same as the reference.
- **Confirmation-step editor**: message `TextField` + timeout `SpinBox`,
  shown only when `requireConfirm` is true — same pattern.
- **Ingredients/BOM table**: name, phase (A–F, color-coded — reuse the
  `PHASE_COLORS` mapping from the reference, translated to your theme's
  color tokens rather than copied verbatim if they clash with the existing
  palette), quantity.
- **Approve button** (Incharge/Administrator only): flips `status` to
  `'approved'`, writes an audit-log row, unlocks it for execution.

## 5. Recipe Execution screen (any operator, monitoring)

Direct translation of the Next.js "Formulation" tab (§6 of your reference):

- **Header card**: recipe selector (read-only during a run), batch-state
  badge (RUNNING/COMPLETE/IDLE), live KPIs (vessel temp, level, batch timer),
  Execute button (only enabled when idle and a recipe is `approved`).
- **Step progression list**: one card per step — done/active/pending
  styling, live step timer, confirm/manual-wait badges, and **nested live
  operation progress bars** (device color dot, progress bar, remaining
  time, live speed) exactly as specified — this is the part that needs the
  shared execution-state object (§6 below) to update smoothly.
- **Right column**: ingredients checklist with phase-status LEDs, equipment
  status panel (one row per real device from §1, pulsing LED + RUNNING/OFF),
  process-values grid (vessel/jacket temp, vacuum, level).
- **Global overlays**: `ConfirmationPopup` (amber, countdown, Confirm/Cancel
  → writes a `batch_events` row either way), `ManualWaitPopup` (blue,
  Continue), `DeleteConfirmDialog` — same visual language as the reference.

## 6. The shared execution-state object (the architectural crux)

The Next.js version polled a global `PlcData` object every 500ms via
`usePlcData` and broadcast it to every open tab/screen via
`BroadcastChannel`. The direct Qt/C++ equivalent:

A C++ `QObject`-derived singleton — call it `RecipeExecutionEngine` — with
`Q_PROPERTY`s (with `NOTIFY` signals) mirroring the reference's
`RecipeExecState`: `recipeLoaded`, `recipeName`, `totalSteps`,
`currentStepIndex`, `currentStepName`, `manualWaiting`,
`confirmRequired`/`confirmMessage`/`confirmCountdown`, and a
`QAbstractListModel`-backed `operations` property (device, status, progress,
remainingSec, currentSpeed per row) so QML `Repeater`/`ListView` bind to it
directly and update reactively — no manual polling needed inside QML itself.

Register it once (`qmlRegisterSingletonInstance` or a root context property
set in `main.cpp`), and **every** screen that needs execution state —
Recipe Execution, the P&ID screen (step progress bar), Controls screen
(slider lock + step banner), Header bar (running-step message) — binds to
the same singleton's properties. This is exactly the "one object, many
screens read it" pattern the reference already uses; it just moves from a
JS hook + BroadcastChannel to a C++ singleton + Qt's property binding, which
is the idiomatic way to do the same thing in this stack. Check whether a
similar singleton already exists in the project (for the live process values
already shown on the control screen) before creating a second one — extend
it rather than duplicate it if so.

## 7. Two built-in recipes to carry over as test data

The reference includes two fully worked recipes (Body Lotion — 14 steps/13
ingredients; Industrial Shampoo — 22 steps/15 ingredients). Port these as
seed data (an INSERT script or a one-time JSON import) once the device names
are remapped per §1 — they're valuable as realistic test cases exercising
every stop-condition type and the ramp behavior, and there's no reason to
invent new test recipes when two well-designed ones already exist.
