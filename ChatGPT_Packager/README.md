# PVA VPU-50 SCADA – ChatGPT Packager & Git-Style Delta System

A Windows-native source code packaging and delta-synchronization utility designed to pair your local development workflow with **ChatGPT Pro**. It enables you to transfer project context, discuss architectural choices, and review code diffs **without repeatedly uploading large ZIP archives or wasting token context**.

---

## 1. Directory Structure

```text
PVA_VPU50_SCADA/
│
├── ChatGPT_Packager/
│   ├── Full_Package.bat          # 1-Click Batch launcher for Full Source Package
│   ├── Delta_Package.bat         # 1-Click Batch launcher for Git-Style Delta Package
│   ├── Pack-Project.ps1          # Core PowerShell packaging & diff engine (PS 5.1 & PS 7)
│   ├── pack-config.json          # File inclusion/exclusion rules and binary filter
│   ├── Test-Packager.ps1         # 12-point automated acceptance & reconstruction test suite
│   ├── README.md                 # This documentation
│   │
│   ├── State/                    # [Ignored by Git] Local comparison baseline
│   │   ├── latest_snapshot.json  # Cryptographic manifest of current baseline
│   │   └── baseline_files/       # File mirror used for diffing and rename detection
│   │
│   └── Output/                   # [Ignored by Git] Timestamped ZIP archives
│       └── YYYYMMDD/
│           ├── FULL_YYYYMMDD_HHMMSS.zip
│           └── DELTA_YYYYMMDD_HHMMSS.zip
```

---

## 2. Quickstart Workflow

### First Time Setup: Establishing the Baseline
1. Double-click `Full_Package.bat` (or run it from terminal).
2. The packager:
   - Automatically detects the repository root.
   - Scans all Qt Quick/QML, Python, C++, CMake, tests, and documentation files.
   - Excludes caches, build artifacts, virtual environments, `.git`, and secrets.
   - Creates a compressed archive under `ChatGPT_Packager/Output/YYYYMMDD/FULL_YYYYMMDD_HHMMSS.zip` (~0.58 MB).
   - Generates `manifest.json` and `PROJECT_CONTEXT.md` inside the ZIP.
   - Preserves a local baseline in `ChatGPT_Packager/State/`.
3. **Upload `FULL_YYYYMMDD_HHMMSS.zip` to ChatGPT.**

### Daily Iteration: Sending Only Changes
1. After editing, refactoring, or running tests in your IDE:
2. Double-click `Delta_Package.bat`.
3. The packager:
   - Computes SHA-256 hashes of every working-directory file against the baseline.
   - Accurately detects:
     * Added files
     * Modified files (including 1-character, whitespace-only, and CRLF vs LF changes)
     * Deleted files
     * Renamed or moved files (100% SHA match)
     * Binary asset changes
   - Generates Git-compatible unified diffs (`changes.patch`).
   - If **no files changed**, it informs you cleanly and **does not create an empty ZIP** to prevent wasting tokens.
   - Creates a compact DELTA ZIP under `ChatGPT_Packager/Output/YYYYMMDD/DELTA_YYYYMMDD_HHMMSS.zip` (~2 KB).
   - Advances the baseline snapshot in `State/` only after ZIP integrity is verified.
4. **Upload only the small DELTA ZIP to your existing ChatGPT chat.**

---

## 3. Contents of the DELTA Package

Every generated DELTA ZIP contains:

```text
DELTA_YYYYMMDD_HHMMSS.zip
├── README_FOR_CHATGPT.md    # Instructions telling ChatGPT how to interpret the update
├── delta_manifest.json      # Machine-readable inventory with old/new SHA-256 hashes & parent ID
├── changes.patch            # Git-style unified patches (--- a/... +++ b/...)
├── CHANGES_SUMMARY.md       # High-level table of changes, line deltas, and touched components
└── changed_binary_files/    # [Only present if binary assets like PNG icons changed]
```

### Prompt to Send to ChatGPT with the Delta ZIP
```text
I have uploaded an incremental delta package (DELTA_YYYYMMDD_HHMMSS.zip) containing my latest updates since the last baseline.
Please review CHANGES_SUMMARY.md for a high-level overview and changes.patch for the exact code diffs.
```

---

## 4. Key Design Principles & Safety Protections

1. **Non-Destructive Git Operation**:
   - The packager queries Git metadata (`git rev-parse HEAD`, `git status --porcelain`) in read-only mode.
   - It **NEVER** runs `git commit`, `git push`, `git checkout`, or `git reset`.
   - Works seamlessly even if Git is not installed (using built-in pure PowerShell unified diff fallback).
2. **Precision Diffing**:
   - Detects single-character modifications.
   - Detects single-space or indentation modifications.
   - Detects line ending alterations (CRLF $\leftrightarrow$ LF).
   - Preserves character encodings (UTF-8, UTF-8-BOM).
3. **Sensitive Data Protection**:
   - Automatically excludes `.env`, secrets, private keys (`.pem`, `.key`), tokens, and database files (`*.db`, `*.sqlite`).
4. **Baseline Atomic Integrity**:
   - The comparison baseline in `ChatGPT_Packager/State/` is never overwritten or advanced until the output ZIP has been successfully written and validated.
   - Each successive delta links back to its exact immediate parent snapshot ID.

---

## 5. Automated Verification Suite (12 Acceptance Tests)

A complete 12-point test harness is included: [`ChatGPT_Packager/Test-Packager.ps1`](file:///c:/Users/Shekhar/Desktop/QT%20DESIGNER%20PROJECTS/PVA_VPU50_SCADA/ChatGPT_Packager/Test-Packager.ps1).

To run the verification suite:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ChatGPT_Packager\Test-Packager.ps1
```

### Covered Test Cases:
| # | Test Scenario | Verification Method | Status |
| :--- | :--- | :--- | :--- |
| **1** | No file changes | Asserts exit code 0, no delta ZIP generated, clean terminal notice | **PASS** |
| **2** | 1 character modified | Asserts diff captures exact character substitution in `changes.patch` | **PASS** |
| **3** | Only 1 space modified | Asserts whitespace-only alteration detected via SHA-256 & patch | **PASS** |
| **4** | New source file added | Asserts file status is `Added` in `delta_manifest.json` | **PASS** |
| **5** | Source file deleted | Asserts file status is `Deleted` and `--- a/file` $\rightarrow$ `+++ /dev/null` in patch | **PASS** |
| **6** | Renamed / moved file | Asserts `Renamed` status with 100% SHA match (`old_path` $\rightarrow$ `new_path`) | **PASS** |
| **7** | Binary asset modified | Asserts binary file is included complete under `changed_binary_files/` | **PASS** |
| **8** | File with spaces in path | Asserts paths containing spaces are handled cleanly | **PASS** |
| **9** | CRLF-to-LF line ending | Asserts line ending change is detected via raw byte SHA-256 | **PASS** |
| **10**| Successive deltas | Asserts snapshot chaining (`Delta 2 -> Delta 1 -> Full`) | **PASS** |
| **11**| Uncommitted Git changes | Asserts detection of uncommitted files in manifest without touching Git tree | **PASS** |
| **12**| Failure handling | Asserts baseline is NOT corrupted or advanced if packaging fails | **PASS** |
| **13**| Byte-for-byte reconstruction| Validates 100% SHA-256 match between chained baseline and working tree | **PASS** |

