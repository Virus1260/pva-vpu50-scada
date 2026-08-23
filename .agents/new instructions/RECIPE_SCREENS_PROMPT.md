# Prompt — paste into Antigravity (Gemini 3.7 Flash, Medium/High effort)

**Before you paste this**: put `recipe-maker-and-execution-spec.md`
(delivered alongside this file) somewhere in the project — e.g.
`docs/recipe-maker-and-execution-spec.md` — since the prompt below points to
it for detail rather than repeating it all inline.

---

## PROMPT STARTS BELOW THIS LINE

You're working in the existing project at
`C:\Users\Shekhar\Desktop\QT DESIGNER PROJECTS\PVA_VPU50_SCADA`, open in this
IDE — a Qt Quick (QML) + C++ industrial SCADA HMI for the PVA Systems VPU-50
ointment-manufacturing vessel skid.

### Step 0 — Orient before writing anything

1. If a `.agent/` folder and/or `AGENTS.md` / `memory/PROJECT_STATUS.md`
   already exist at the project root, read them first — they carry
   established decisions (tech stack, tag names, existing component
   inventory, an EKATO-branding cleanup task) from prior sessions. If none
   exist, proceed from this prompt and the spec file alone, and create
   `memory/PROJECT_STATUS.md` as you go so the next session isn't starting
   cold.
2. Read `docs/recipe-maker-and-execution-spec.md` in full before writing any
   code — it has the actual data model, screen breakdown, and architecture
   this prompt summarizes.
3. Inventory the current project (`Get-ChildItem -Recurse -Include *.qml,*.cpp,*.h`)
   to see what already exists — especially anything named `Recipe*`,
   `Formulation*`, or a `RecipesScreen.qml` — before creating new files that
   might duplicate them.

### The task

Build two screens: **Recipe Maker** (authoring, restricted to
Incharge/Supervisor and Administrator roles) and **Recipe Execution**
(running/monitoring, available to any logged-in operator). These are two
separate screens, not tabs on one screen — that's an intentional change from
the Next.js reference this is based on (see below), driven by the access-
level split.

**Reference material**: a prior session deeply analyzed an existing,
well-designed Next.js implementation of this exact concept (project:
`VPU10-Batch-Reactor-Control`, at `E:\git_desktop\VPU10-Batch-Reactor-Control`).
That analysis is reproduced in full in `docs/recipe-maker-and-execution-spec.md`
§0 (what to keep vs. change) through §7. Treat the *data model and UX
patterns* from that reference as the thing to faithfully translate — device
list, stop-condition types, the ramp behavior, the confirmation/manual-wait
popups, the cross-screen wiring — into idiomatic QML/C++, not something to
redesign from scratch. Where the spec says something is changing (SQLite
instead of localStorage, real P&ID tag names instead of generic device
labels, two screens instead of one, recipe/batch-run separation, RBAC), that
change is deliberate — implement it that way, don't revert to the reference's
original choice.

### Four things that matter most

1. **Set up SQLite via QtSql first** (`docs/recipe-maker-and-execution-spec.md`
   §2) — schema, one file per machine via `QStandardPaths::AppDataLocation`.
   This is Phase 0; the two screens are built against this, not against
   in-memory or JSON-file state.
2. **A recipe and a batch run are different, separate objects** (spec §2.3).
   Executing a recipe snapshots it into an immutable `batch_runs` row. Never
   let the live execution engine read from the editable `recipes` table
   directly.
3. **Role-gate the Recipe Maker screen** (spec §3) — Operators don't get the
   nav icon for it at all, not a blocked click.
4. **Device names are real P&ID tags** (spec §1), not the reference's
   generic `agitator`/`homogenizer`/etc. labels. Where the exact real tag
   for fill/drain valves isn't obvious, mark `// TODO: confirm with
   Shekhar` rather than guessing.

### Architecture

Build (or extend, if something similar already exists — check first) a
single C++ `RecipeExecutionEngine` singleton exposing the live execution
state as `Q_PROPERTY`s + a list model, per spec §6. Every screen that needs
execution state (Recipe Execution, the P&ID screen, the Controls screen, the
Header bar) binds to this one singleton — don't give each screen its own
polling logic.

### Working method

- Reuse existing themed widgets (`Scada*.qml`) over raw `QtQuick.Controls`
  where the project already has an equivalent, per whatever asset inventory
  exists in this project (check `.agent/04` if present, or inventory
  directly if not).
- Comment for a non-coder reader.
- Run an accessibility pass (contrast, non-color-alone state, touch targets)
  on both new screens.
- Port the two reference recipes (Body Lotion, Industrial Shampoo — spec §7)
  as seed data once device names are remapped, for realistic testing.
- Before writing non-trivial code, ask: *"Does a standard Qt Quick control or
  an existing project component already do this?"* and *"Is this tag/device
  name real, or am I guessing?"*

### When done

Summarize what's built, what's `TODO: confirm`, and any place the real
project structure didn't match this prompt's assumptions (e.g. no existing
`.agent/` folder, or a differently-named existing recipe screen) — and
update `memory/PROJECT_STATUS.md`.

## PROMPT ENDS ABOVE THIS LINE
