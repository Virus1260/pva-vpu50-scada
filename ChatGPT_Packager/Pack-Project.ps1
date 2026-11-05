<#
.SYNOPSIS
    PVA VPU-50 SCADA - Reproducible Project Source Packager & Git-Style Delta System.
.DESCRIPTION
    Creates FULL source-code packages and token-efficient, Git-style DELTA packages
    for seamless integration with ChatGPT.
    Supports Windows 10 & 11, PowerShell 5.1 and PowerShell 7+.
.PARAMETER Mode
    Packaging mode: 'Full', 'Delta', 'Status', or 'Verify'. Default is 'Full'.
.PARAMETER ConfigPath
    Path to pack-config.json. Defaults to pack-config.json in script directory.
.PARAMETER VerboseLog
    Enable detailed logging output.
#>

[CmdletBinding()]
param(
    [ValidateSet("Full", "Delta", "Status", "Verify")]
    [string]$Mode = "Full",

    [string]$ConfigPath = "",

    [switch]$VerboseLog,

    [switch]$NoBaselineUpdate
)

Set-StrictMode -Off
$ErrorActionPreference = "Stop"

# Ensure Compression assemblies are loaded (.NET 4.5+ on Windows PowerShell 5.1 & PS 7)
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

# ==============================================================================
# Helper Functions: Paths and Configuration
# ==============================================================================

function Get-PackagerRoot {
    return $PSScriptRoot
}

function Get-ProjectRepoRoot {
    param([string]$ScriptDir)
    $candidate = (Resolve-Path "$ScriptDir\..").Path
    if ((Test-Path "$candidate\CMakeLists.txt") -or (Test-Path "$candidate\PVA_VPU50_SCADA.qmlproject") -or (Test-Path "$candidate\.git")) {
        return $candidate
    }
    # Fallback search up to 3 parent directories
    $dir = (Get-Item $ScriptDir).Parent
    while ($dir -ne $null) {
        if ((Test-Path "$($dir.FullName)\CMakeLists.txt") -or (Test-Path "$($dir.FullName)\PVA_VPU50_SCADA.qmlproject")) {
            return $dir.FullName
        }
        $dir = $dir.Parent
    }
    return $candidate
}

function Load-PackConfig {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        throw "Configuration file not found at: $Path"
    }
    $raw = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    return ConvertFrom-Json $raw
}

# ==============================================================================
# Helper Functions: Hashing, Encodings, and File Classification
# ==============================================================================

function Get-FileSha256 {
    param([string]$FilePath)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $stream = [System.IO.File]::OpenRead($FilePath)
    try {
        $hashBytes = $sha.ComputeHash($stream)
        $sb = New-Object System.Text.StringBuilder
        foreach ($b in $hashBytes) {
            [void]$sb.Append($b.ToString("x2"))
        }
        return $sb.ToString()
    }
    finally {
        $stream.Close()
        $sha.Dispose()
    }
}

function Get-BytesSha256 {
    param([byte[]]$Bytes)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hashBytes = $sha.ComputeHash($Bytes)
        $sb = New-Object System.Text.StringBuilder
        foreach ($b in $hashBytes) {
            [void]$sb.Append($b.ToString("x2"))
        }
        return $sb.ToString()
    }
    finally {
        $sha.Dispose()
    }
}

function Test-IsBinaryContent {
    param([string]$FilePath, [string[]]$BinaryExtensions)
    $ext = [System.IO.Path]::GetExtension($FilePath).ToLowerInvariant()
    if ($BinaryExtensions -contains $ext) {
        return $true
    }

    # Inspect first 4096 bytes for null character
    $stream = [System.IO.File]::OpenRead($FilePath)
    try {
        $buffer = New-Object byte[] 4096
        $read = $stream.Read($buffer, 0, $buffer.Length)
        for ($i = 0; $i -lt $read; $i++) {
            if ($buffer[$i] -eq 0) {
                return $true
            }
        }
        return $false
    }
    finally {
        $stream.Close()
    }
}

function Get-TextEncodingInfo {
    param([string]$FilePath)
    $stream = [System.IO.File]::OpenRead($FilePath)
    try {
        $bom = New-Object byte[] 4
        $read = $stream.Read($bom, 0, 4)
        if ($read -ge 3 -and $bom[0] -eq 0xEF -and $bom[1] -eq 0xBB -and $bom[2] -eq 0xBF) {
            return "UTF-8-BOM"
        }
        if ($read -ge 2 -and $bom[0] -eq 0xFF -and $bom[1] -eq 0xFE) {
            return "UTF-16LE"
        }
        if ($read -ge 2 -and $bom[0] -eq 0xFE -and $bom[1] -eq 0xFF) {
            return "UTF-16BE"
        }
        if ($read -ge 4 -and $bom[0] -eq 0x00 -and $bom[1] -eq 0x00 -and $bom[2] -eq 0xFE -and $bom[3] -eq 0xFF) {
            return "UTF-32BE"
        }
        return "UTF-8"
    }
    finally {
        $stream.Close()
    }
}

function Detect-LineEndings {
    param([string]$FilePath)
    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
    $hasCr = $false
    $hasLf = $false
    $crlfCount = 0
    $lfCount = 0

    for ($i = 0; $i -lt $bytes.Length; $i++) {
        if ($bytes[$i] -eq 13) {
            if (($i + 1) -lt $bytes.Length -and $bytes[$i + 1] -eq 10) {
                $crlfCount++
                $i++
            }
        }
        elseif ($bytes[$i] -eq 10) {
            $lfCount++
        }
    }

    if ($crlfCount -gt 0 -and $lfCount -eq 0) { return "CRLF" }
    if ($lfCount -gt 0 -and $crlfCount -eq 0) { return "LF" }
    if ($crlfCount -gt 0 -and $lfCount -gt 0) { return "Mixed" }
    return "None"
}

# ==============================================================================
# Git Metadata Inspection (Safe & Non-Destructive)
# ==============================================================================

function Get-SafeGitMetadata {
    param([string]$RepoRoot)
    $meta = @{
        Installed = $false
        CommitHash = "N/A"
        Branch = "N/A"
        HasUncommitted = $false
        StatusSummary = "Git not detected or uninitialized"
    }

    try {
        $gitVersion = git --version 2>$null
        if ($gitVersion) {
            $meta.Installed = $true
            if (Test-Path "$RepoRoot\.git") {
                $headHash = git -C "$RepoRoot" rev-parse HEAD 2>$null
                if ($headHash) {
                    $meta.CommitHash = $headHash.Trim()
                }
                $branchName = git -C "$RepoRoot" rev-parse --abbrev-ref HEAD 2>$null
                if ($branchName) {
                    $meta.Branch = $branchName.Trim()
                }
                $status = git -C "$RepoRoot" status --porcelain 2>$null
                if ($status -and $status.Trim().Length -gt 0) {
                    $meta.HasUncommitted = $true
                    $meta.StatusSummary = "Working tree has uncommitted modifications"
                }
                else {
                    $meta.HasUncommitted = $false
                    $meta.StatusSummary = "Clean working tree"
                }
            }
        }
    }
    catch {
        # Safe fallback: Git not present or command failed
    }

    return $meta
}

# ==============================================================================
# File Scanning & Inclusion Logic
# ==============================================================================

function Test-PathIsExcluded {
    param(
        [string]$RelativePath,
        [string[]]$ExcludeDirectories,
        [string[]]$ExcludeFilePatterns
    )

    $normPath = $RelativePath.Replace("\", "/")

    # Exclude directories
    foreach ($exDir in $ExcludeDirectories) {
        $normEx = $exDir.Replace("\", "/")
        if ($normPath -eq $normEx -or $normPath.StartsWith("$normEx/")) {
            return $true
        }
    }

    # Exclude file patterns
    $fileName = [System.IO.Path]::GetFileName($RelativePath)
    foreach ($pat in $ExcludeFilePatterns) {
        if ($fileName -like $pat -or $normPath -like $pat) {
            return $true
        }
    }

    return $false
}

function Scan-ProjectSourceFiles {
    param(
        [string]$RepoRoot,
        [PSObject]$Config,
        [switch]$Verbose
    )

    $scannedFiles = @{}
    $skippedCount = 0
    $skippedFiles = @()

    $incExts = [string[]]($Config.includeExtensions)
    $binExts = [string[]]($Config.binaryExtensions)
    $exDirs = [string[]]($Config.excludeDirectories)
    $exPatterns = [string[]]($Config.excludeFilePatterns)
    $rootFiles = [string[]]($Config.includeRootFiles)
    $incDirs = [string[]]($Config.includeDirectories)

    # 1. Scan explicit root files
    foreach ($rf in $rootFiles) {
        $fullPath = Join-Path $RepoRoot $rf
        if (Test-Path $fullPath -PathType Leaf) {
            $rel = $rf.Replace("\", "/")
            if (-not (Test-PathIsExcluded -RelativePath $rel -ExcludeDirectories $exDirs -ExcludeFilePatterns $exPatterns)) {
                $sha = Get-FileSha256 $fullPath
                $len = (Get-Item $fullPath).Length
                $isBin = Test-IsBinaryContent $fullPath $binExts
                $enc = if ($isBin) { "Binary" } else { Get-TextEncodingInfo $fullPath }
                $le = if ($isBin) { "N/A" } else { Detect-LineEndings $fullPath }
                $scannedFiles[$rel] = @{
                    Path = $rel
                    FullPath = $fullPath
                    Sha256 = $sha
                    Size = $len
                    IsBinary = $isBin
                    Encoding = $enc
                    LineEndings = $le
                    Type = [System.IO.Path]::GetExtension($fullPath).TrimStart(".").ToUpperInvariant()
                }
            }
        }
    }

    # 2. Scan includeDirectories
    foreach ($id in $incDirs) {
        $dirPath = Join-Path $RepoRoot $id
        if (Test-Path $dirPath -PathType Container) {
            $items = Get-ChildItem -Path $dirPath -Recurse -File -Force -ErrorAction SilentlyContinue
            foreach ($item in $items) {
                # Prevent symbolic link breakout
                if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                    $skippedCount++
                    $skippedFiles += "Symlink skipped: $($item.FullName)"
                    continue
                }

                $rel = ($item.FullName.Substring($RepoRoot.Length)).TrimStart("\", "/").Replace("\", "/")

                if (Test-PathIsExcluded -RelativePath $rel -ExcludeDirectories $exDirs -ExcludeFilePatterns $exPatterns) {
                    continue
                }

                $ext = [System.IO.Path]::GetExtension($item.FullName).ToLowerInvariant()
                # Check extension inclusion unless extension is empty and file is specified
                if ($incExts -contains $ext -or $ext -eq "") {
                    $sha = Get-FileSha256 $item.FullName
                    $isBin = Test-IsBinaryContent $item.FullName $binExts
                    $enc = if ($isBin) { "Binary" } else { Get-TextEncodingInfo $item.FullName }
                    $le = if ($isBin) { "N/A" } else { Detect-LineEndings $item.FullName }
                    $typeStr = if ($ext -ne "") { $ext.TrimStart(".").ToUpperInvariant() } else { "FILE" }

                    $scannedFiles[$rel] = @{
                        Path = $rel
                        FullPath = $item.FullName
                        Sha256 = $sha
                        Size = $item.Length
                        IsBinary = $isBin
                        Encoding = $enc
                        LineEndings = $le
                        Type = $typeStr
                    }
                }
                else {
                    $skippedCount++
                    if ($Verbose) {
                        $skippedFiles += "Extension not in include list: $rel"
                    }
                }
            }
        }
    }

    return @{
        Files = $scannedFiles
        SkippedCount = $skippedCount
        SkippedLog = $skippedFiles
    }
}

# ==============================================================================
# Unified Diff Generation Engine (Git + Pure PowerShell Fallback)
# ==============================================================================

function Generate-FileUnifiedDiff {
    param(
        [string]$OldFilePath,
        [string]$NewFilePath,
        [string]$RelativePath,
        [string]$OldSha256 = "",
        [string]$NewSha256 = "",
        [bool]$IsGitAvailable = $true
    )

    $oldShort = if ($OldSha256.Length -ge 7) { $OldSha256.Substring(0, 7) } else { "0000000" }
    $newShort = if ($NewSha256.Length -ge 7) { $NewSha256.Substring(0, 7) } else { "0000000" }

    # Case A: Git diff engine
    if ($IsGitAvailable) {
        try {
            $pinfo = New-Object System.Diagnostics.ProcessStartInfo
            $pinfo.FileName = "git"
            $pinfo.Arguments = "diff --no-index --text -- `"$OldFilePath`" `"$NewFilePath`""
            $pinfo.RedirectStandardOutput = $true
            $pinfo.RedirectStandardError = $true
            $pinfo.UseShellExecute = $false
            $pinfo.CreateNoWindow = $true
            $pinfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8
            $proc = [System.Diagnostics.Process]::Start($pinfo)
            $gitOutput = $proc.StandardOutput.ReadToEnd()
            $proc.WaitForExit()

            if ($gitOutput -and $gitOutput.Trim().Length -gt 0) {
                # Format header to standard Git unified diff
                $lines = $gitOutput -split "`r?`n"
                $hunkStartIndex = -1
                for ($i = 0; $i -lt $lines.Length; $i++) {
                    if ($lines[$i] -like "@@ * @@*") {
                        $hunkStartIndex = $i
                        break
                    }
                }

                $sb = New-Object System.Text.StringBuilder
                [void]$sb.AppendLine("diff --git a/$RelativePath b/$RelativePath")
                [void]$sb.AppendLine("index $oldShort..$newShort 100644")
                [void]$sb.AppendLine("--- a/$RelativePath")
                [void]$sb.AppendLine("+++ b/$RelativePath")

                if ($hunkStartIndex -ge 0) {
                    for ($i = $hunkStartIndex; $i -lt $lines.Length; $i++) {
                        [void]$sb.AppendLine($lines[$i])
                    }
                }
                else {
                    # No hunks (e.g. empty diff), just append output
                    [void]$sb.AppendLine($gitOutput)
                }

                return $sb.ToString()
            }
        }
        catch {
            # Fall through to PowerShell pure diff generator
        }
    }

    # Case B: Pure PowerShell Unified Diff Fallback
    $oldLines = if ($OldFilePath -eq "/dev/null" -or -not (Test-Path $OldFilePath)) { @() } else { [System.IO.File]::ReadAllLines($OldFilePath, [System.Text.Encoding]::UTF8) }
    $newLines = if ($NewFilePath -eq "/dev/null" -or -not (Test-Path $NewFilePath)) { @() } else { [System.IO.File]::ReadAllLines($NewFilePath, [System.Text.Encoding]::UTF8) }

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("diff --git a/$RelativePath b/$RelativePath")
    [void]$sb.AppendLine("index $oldShort..$newShort 100644")
    $srcHeader = if ($OldFilePath -eq "/dev/null") { "--- /dev/null" } else { "--- a/$RelativePath" }
    $dstHeader = if ($NewFilePath -eq "/dev/null") { "+++ /dev/null" } else { "+++ b/$RelativePath" }
    [void]$sb.AppendLine($srcHeader)
    [void]$sb.AppendLine($dstHeader)

    # Simplified single-hunk replacement for fallback
    [void]$sb.AppendLine("@@ -1,$($oldLines.Length) +1,$($newLines.Length) @@")
    foreach ($ol in $oldLines) {
        [void]$sb.AppendLine("-$ol")
    }
    foreach ($nl in $newLines) {
        [void]$sb.AppendLine("+$nl")
    }

    return $sb.ToString()
}

# ==============================================================================
# Project Context Documentation Generator
# ==============================================================================

function Generate-ProjectContextMd {
    param(
        [string]$SnapshotId,
        [hashtable]$GitMeta,
        [int]$TotalFiles,
        [long]$TotalBytes
    )

    $sizeMb = [Math]::Round(($TotalBytes / 1MB), 2)
    $ts = [DateTime]::UtcNow.ToString("yyyy-MM-dd HH:mm:ss 'UTC'")

    return @"
# PVA Systems VPU-50 Industrial SCADA – Project Context & Architecture

**Package Snapshot:** `$SnapshotId`  
**Generated At:** $ts  
**Total Source Files:** $TotalFiles (`$sizeMb MB)  
**Git Baseline:** $($GitMeta.CommitHash) (Branch: $($GitMeta.Branch))  
**Working Tree Status:** $($GitMeta.StatusSummary)  

---

## 1. System Overview & Technology Stack
The **PVA VPU-50 SCADA / MES Platform** controls a pharmaceutical/cosmetic industrial vacuum mixing skid. It interfaces directly with a **Delta AS332T-A PLC** over **Modbus TCP (Port 502, Target: 192.168.1.5)**.

* **UI Layer:** Qt Quick 6.8 / QML 2.15 (declarative `.ui.qml` Views + `.qml` Controllers).
* **Application Host:** Python 3.11+ / PySide6 (`main.py`).
* **Web / Cloud Deployment:** Qt 6 WebAssembly (`wasm_singlethread`) deployed to Vercel with COOP/COEP isolation.
* **Database & Persistence:** SQLite embedded (`audit.db`, `historian.db`) with cryptographic SHA-256 hash chaining (21 CFR Part 11 compliant).
* **Industrial PLC Rack:** Delta AS332T-A CPU, PS02 Power, AS16AM (16 DI), AS04AD (4 AI), AS04DA (4 AO), AS06RTD (6 Temp RTD).

---

## 2. Screen & Navigation Map (6 Pure Industrial Screens)
1. **Screen 0 (Control):** `PVA_VPU50_SCADAContent/screens/Screen_1_Control.qml` - Process rows, speed setpoints, live motors, interlock annunciator.
2. **Screen 1 (P&ID):** `PVA_VPU50_SCADAContent/screens/Screen_2_P_ID.qml` - Vector synoptic layout with live pipes, valve matrix, and agitator animations.
3. **Screen 2 (Trends):** `PVA_VPU50_SCADAContent/screens/Screen_3_Trends.qml` - Historical multi-pen charts (LTTB downsampled telemetry).
4. **Screen 3 (Alarms):** `PVA_VPU50_SCADAContent/screens/Screen_4_Alarms.qml` - ISA-18.2 alarm management and operator acknowledgement.
5. **Screen 4 (Audit Log):** `PVA_VPU50_SCADAContent/screens/Screen_6_AuditTrail.qml` - Cryptographically chained 21 CFR Part 11 audit records.
6. **Screen 5 (Diagnostics):** `PVA_VPU50_SCADAContent/screens/Screen_8_Diagnostics.qml` - Live Modbus register inspector, hardware comms, ping latency.

---

## 3. Key Entry Points & Directory Structure
```text
PVA_VPU50_SCADA/
├── main.py                          [Desktop launcher & PySide6 bridge]
├── PVA_VPU50_SCADA.qmlproject       [Qt Design Studio project manifest]
├── PVA_VPU50_SCADA.qrc              [Qt resource bundle]
├── CMakeLists.txt & qds.cmake       [C++ / QML build configurations]
├── PVA_VPU50_SCADAContent/          [Qt Quick QML source code]
│   ├── App.qml                      [QML application root]
│   ├── Main_frame_screen.qml        [Controller & Shell state]
│   ├── Main_frame_screenView.ui.qml [Declarative View frame]
│   ├── screens/                     [Individual operational screens]
│   └── components/                  [Modular UI widgets & modals]
├── scada/                           [Python backend services]
│   ├── controller.py                [Main SCADA orchestrator]
│   ├── audit.py                     [21 CFR Part 11 audit trail]
│   ├── historian.py                 [LTTB time-series telemetry]
│   └── modbus/                      [Industrial Ethernet worker]
│       ├── worker.py                [Modbus TCP polling thread]
│       └── delta_map.py             [Delta AS332T register addresses]
└── tests/                           [Automated compliance test suite]
```

---

## 4. Invariant Rules for ChatGPT Development
1. **Separation of Concerns:** `.ui.qml` files are declarative Views only! Never place JavaScript functions or constructor calls (`String(...)`) inside `.ui.qml` (Rule M222). Logic belongs in `.qml`.
2. **Process Safety Interlock:** When an equipment row is running (`isPlaying == true`), its speed setpoint, steppers, and mode modals are safety-locked.
3. **No Unicode Emojis:** Use SVG icons from `assets/icons/` via `ScadaIcon.qml`.
4. **Test Suite Verification:** Run `python -m unittest discover tests` on any change. All 14 tests must pass.
"@
}

# ==============================================================================
# Changes Summary & Readme Generator
# ==============================================================================

function Generate-ChangesSummaryMd {
    param(
        [string]$DeltaSnapshotId,
        [string]$ParentSnapshotId,
        [hashtable]$GitMeta,
        [array]$AddedList,
        [array]$ModifiedList,
        [array]$DeletedList,
        [array]$RenamedList,
        [array]$BinaryList
    )

    $ts = [DateTime]::UtcNow.ToString("yyyy-MM-dd HH:mm:ss 'UTC'")
    $totalChanges = $AddedList.Count + $ModifiedList.Count + $DeletedList.Count + $RenamedList.Count

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("# Delta Package Changes Summary: $DeltaSnapshotId")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("**Parent Baseline:** `$ParentSnapshotId`  ")
    [void]$sb.AppendLine("**Generated At:** $ts  ")
    [void]$sb.AppendLine("**Git Commit:** $($GitMeta.CommitHash) (Branch: $($GitMeta.Branch))  ")
    [void]$sb.AppendLine("**Total Files Changed:** $totalChanges  ")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("### Summary of Change Counts")
    [void]$sb.AppendLine("- **Added Files:** $($AddedList.Count)")
    [void]$sb.AppendLine("- **Modified Files:** $($ModifiedList.Count)")
    [void]$sb.AppendLine("- **Deleted Files:** $($DeletedList.Count)")
    [void]$sb.AppendLine("- **Renamed / Moved Files:** $($RenamedList.Count)")
    [void]$sb.AppendLine("- **Binary Files Changed:** $($BinaryList.Count)")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("### Detailed Path Inventory")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("| Status | File Path | Type | Old Size | New Size | Details |")
    [void]$sb.AppendLine("| :--- | :--- | :--- | :--- | :--- | :--- |")

    foreach ($item in $RenamedList) {
        [void]$sb.AppendLine("| **Renamed** | `$($item.OldPath)` -> `$($item.NewPath)` | $($item.Type) | $($item.Size) B | $($item.Size) B | 100% SHA match |")
    }

    foreach ($item in $AddedList) {
        $binTag = if ($item.IsBinary) { "[Binary]" } else { "Text" }
        [void]$sb.AppendLine("| **Added** | `$($item.Path)` | $($item.Type) | 0 B | $($item.Size) B | $binTag ($($item.Encoding)) |")
    }

    foreach ($item in $ModifiedList) {
        $binTag = if ($item.IsBinary) { "[Binary]" } else { "Text ($($item.Encoding))" }
        $diffSize = $item.NewSize - $item.OldSize
        $diffStr = if ($diffSize -ge 0) { "+$diffSize B" } else { "$diffSize B" }
        [void]$sb.AppendLine("| **Modified** | `$($item.Path)` | $($item.Type) | $($item.OldSize) B | $($item.NewSize) B | $diffStr, $binTag |")
    }

    foreach ($item in $DeletedList) {
        [void]$sb.AppendLine("| **Deleted** | `$($item.Path)` | $($item.Type) | $($item.Size) B | 0 B | File removed |")
    }

    return $sb.ToString()
}

function Generate-ReadmeForChatGpt {
    param(
        [string]$DeltaSnapshotId,
        [string]$ParentSnapshotId
    )

    return @"
# README FOR CHATGPT – PVA VPU-50 SCADA DELTA PACKAGE

**Delta Snapshot:** `$DeltaSnapshotId`  
**Parent Baseline Snapshot:** `$ParentSnapshotId`  

## How to Review and Process this Delta:
1. **Read `CHANGES_SUMMARY.md` first**: This provides a bird's-eye view of all added, modified, deleted, and renamed files.
2. **Inspect `changes.patch`**: This file contains standard Git-compatible unified diffs (`--- a/...` and `+++ b/...`) for all modified and newly added text files. Whitespace, indentation, line endings, and character modifications are preserved with full precision.
3. **Inspect `delta_manifest.json`**: This machine-readable file records exact SHA-256 hashes for all parent and new states, enabling exact verification.
4. **Check `changed_binary_files/`**: If present, this directory contains any complete updated binary assets (such as PNG icons or fonts) that cannot be expressed as a text patch.

## Context Application:
You can directly review code diffs in `changes.patch` or apply them to the project code from your baseline snapshot `$ParentSnapshotId`.
"@
}

# ==============================================================================
# FULL PACKAGE MODE
# ==============================================================================

function Invoke-FullPackage {
    param(
        [string]$RepoRoot,
        [string]$PackagerDir,
        [PSObject]$Config,
        [hashtable]$GitMeta,
        [switch]$Verbose
    )

    $dateFolder = Get-Date -Format "yyyyMMdd"
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $snapshotId = "FULL_$timestamp"
    $outputDir = Join-Path $PackagerDir "Output\$dateFolder"
    $stateDir = Join-Path $PackagerDir "State"
    $baselineFilesDir = Join-Path $stateDir "baseline_files"

    if (-not (Test-Path $outputDir)) {
        [void](New-Item -ItemType Directory -Path $outputDir -Force)
    }
    if (-not (Test-Path $stateDir)) {
        [void](New-Item -ItemType Directory -Path $stateDir -Force)
    }

    $zipPath = Join-Path $outputDir "$snapshotId.zip"
    if (Test-Path $zipPath) {
        # Never overwrite: add secondary suffix
        $zipPath = Join-Path $outputDir "${snapshotId}_1.zip"
    }

    Write-Host "[1/5] Scanning project repository at: $RepoRoot" -ForegroundColor Cyan
    $scanResult = Scan-ProjectSourceFiles -RepoRoot $RepoRoot -Config $Config -Verbose:$Verbose
    $files = $scanResult.Files
    $totalCount = $files.Count
    $totalBytes = 0
    foreach ($k in $files.Keys) {
        $totalBytes += $files[$k].Size
    }

    Write-Host "      Found $totalCount source files ($([Math]::Round($totalBytes / 1MB, 2)) MB)." -ForegroundColor Green
    if ($scanResult.SkippedCount -gt 0) {
        Write-Host "      Skipped $($scanResult.SkippedCount) excluded/non-source items." -ForegroundColor Gray
    }

    Write-Host "[2/5] Generating Manifest and Project Context..." -ForegroundColor Cyan
    $manifestData = @{
        snapshot_id = $snapshotId
        mode = "Full"
        created_at = [DateTime]::UtcNow.ToString("o")
        git_commit = $GitMeta.CommitHash
        git_branch = $GitMeta.Branch
        git_uncommitted_changes = $GitMeta.HasUncommitted
        total_files = $totalCount
        total_size_bytes = $totalBytes
        files = @()
    }

    foreach ($rel in ($files.Keys | Sort-Object)) {
        $f = $files[$rel]
        $manifestData.files += @{
            path = $f.Path
            sha256 = $f.Sha256
            size = $f.Size
            type = $f.Type
            is_binary = $f.IsBinary
            encoding = $f.Encoding
            line_endings = $f.LineEndings
        }
    }

    $manifestJson = ConvertTo-Json $manifestData -Depth 5
    $projectContextMd = Generate-ProjectContextMd -SnapshotId $snapshotId -GitMeta $GitMeta -TotalFiles $totalCount -TotalBytes $totalBytes

    Write-Host "[3/5] Building compressed Full Source Archive: $zipPath" -ForegroundColor Cyan
    
    # Create ZIP archive directly using ZipArchive
    $zipFileStream = [System.IO.File]::Open($zipPath, [System.IO.FileMode]::CreateNew)
    $archive = New-Object System.IO.Compression.ZipArchive($zipFileStream, [System.IO.Compression.ZipArchiveMode]::Create)

    try {
        # Add Manifest
        $manifestEntry = $archive.CreateEntry("manifest.json", [System.IO.Compression.CompressionLevel]::Optimal)
        $mStream = $manifestEntry.Open()
        $mBytes = [System.Text.Encoding]::UTF8.GetBytes($manifestJson)
        $mStream.Write($mBytes, 0, $mBytes.Length)
        $mStream.Close()

        # Add Project Context
        $ctxEntry = $archive.CreateEntry("PROJECT_CONTEXT.md", [System.IO.Compression.CompressionLevel]::Optimal)
        $cStream = $ctxEntry.Open()
        $cBytes = [System.Text.Encoding]::UTF8.GetBytes($projectContextMd)
        $cStream.Write($cBytes, 0, $cBytes.Length)
        $cStream.Close()

        # Add all source files
        $counter = 0
        foreach ($rel in ($files.Keys | Sort-Object)) {
            $f = $files[$rel]
            $entry = $archive.CreateEntry($f.Path, [System.IO.Compression.CompressionLevel]::Optimal)
            $eStream = $entry.Open()
            $srcBytes = [System.IO.File]::ReadAllBytes($f.FullPath)
            $eStream.Write($srcBytes, 0, $srcBytes.Length)
            $eStream.Close()
            $counter++
        }
    }
    finally {
        $archive.Dispose()
        $zipFileStream.Dispose()
    }

    Write-Host "[4/5] Verifying ZIP archive integrity..." -ForegroundColor Cyan
    $testZip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    $entryCount = $testZip.Entries.Count
    $testZip.Dispose()

    if ($entryCount -lt ($totalCount + 2)) {
        throw "ZIP verification failed: Expected at least $($totalCount + 2) entries, but found $entryCount."
    }
    $zipSize = (Get-Item $zipPath).Length
    Write-Host "      Archive verified! Entries: $entryCount | Compressed size: $([Math]::Round($zipSize / 1MB, 2)) MB." -ForegroundColor Green

    Write-Host "[5/5] Updating local baseline snapshot in State/..." -ForegroundColor Cyan
    
    # Save latest snapshot manifest
    $stateManifestPath = Join-Path $stateDir "latest_snapshot.json"
    [System.IO.File]::WriteAllText($stateManifestPath, $manifestJson, [System.Text.Encoding]::UTF8)

    # Save baseline file mirror
    if (Test-Path $baselineFilesDir) {
        Remove-Item -Path $baselineFilesDir -Recurse -Force
    }
    [void](New-Item -ItemType Directory -Path $baselineFilesDir -Force)

    foreach ($rel in $files.Keys) {
        $destPath = Join-Path $baselineFilesDir $rel
        $destParent = [System.IO.Path]::GetDirectoryName($destPath)
        if (-not (Test-Path $destParent)) {
            [void](New-Item -ItemType Directory -Path $destParent -Force)
        }
        [System.IO.File]::Copy($files[$rel].FullPath, $destPath, $true)
    }

    Write-Host "      Baseline successfully synchronized ($totalCount files mirrored)." -ForegroundColor Green

    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Green
    Write-Host "  [FULL PACKAGE READY FOR CHATGPT]" -ForegroundColor Green
    Write-Host "  ZIP Location: $zipPath" -ForegroundColor Yellow
    Write-Host "  Total Files : $totalCount source files + manifest.json + PROJECT_CONTEXT.md"
    Write-Host "  Size        : $([Math]::Round($zipSize / 1MB, 2)) MB"
    Write-Host "======================================================================" -ForegroundColor Green
    return $zipPath
}

# ==============================================================================
# DELTA PACKAGE MODE
# ==============================================================================

function Invoke-DeltaPackage {
    param(
        [string]$RepoRoot,
        [string]$PackagerDir,
        [PSObject]$Config,
        [hashtable]$GitMeta,
        [switch]$Verbose
    )

    $stateDir = Join-Path $PackagerDir "State"
    $baselineManifestPath = Join-Path $stateDir "latest_snapshot.json"
    $baselineFilesDir = Join-Path $stateDir "baseline_files"

    if (-not (Test-Path $baselineManifestPath) -or -not (Test-Path $baselineFilesDir)) {
        Write-Host ""
        Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
        Write-Host "  [ERROR] No baseline snapshot found in ChatGPT_Packager/State/!" -ForegroundColor Red
        Write-Host "  You must run Full_Package.bat first to create an initial baseline." -ForegroundColor Yellow
        Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
        exit 1
    }

    Write-Host "[1/6] Loading baseline snapshot: $baselineManifestPath" -ForegroundColor Cyan
    $baselineRaw = [System.IO.File]::ReadAllText($baselineManifestPath, [System.Text.Encoding]::UTF8)
    $baseline = ConvertFrom-Json $baselineRaw
    $parentSnapshotId = $baseline.snapshot_id
    Write-Host "      Parent baseline: $parentSnapshotId (Created: $($baseline.created_at))" -ForegroundColor Gray

    $baselineMap = @{}
    foreach ($bf in $baseline.files) {
        $baselineMap[$bf.path] = $bf
    }

    Write-Host "[2/6] Scanning current working directory..." -ForegroundColor Cyan
    $scanResult = Scan-ProjectSourceFiles -RepoRoot $RepoRoot -Config $Config -Verbose:$Verbose
    $currentMap = $scanResult.Files
    Write-Host "      Found $($currentMap.Count) active source files." -ForegroundColor Gray

    Write-Host "[3/6] Computing cryptographic SHA-256 diffs against baseline..." -ForegroundColor Cyan

    $addedList = @()
    $modifiedList = @()
    $deletedList = @()
    $renamedList = @()
    $binaryList = @()

    # Detect Modified and Deleted
    $candidateDeleted = @{}
    foreach ($p in $baselineMap.Keys) {
        $bFile = $baselineMap[$p]
        if (-not $currentMap.ContainsKey($p)) {
            $candidateDeleted[$p] = $bFile
        }
        else {
            $cFile = $currentMap[$p]
            if ($bFile.sha256 -ne $cFile.Sha256) {
                # File content modified
                $modObj = @{
                    Path = $p
                    OldSha256 = $bFile.sha256
                    NewSha256 = $cFile.Sha256
                    OldSize = $bFile.size
                    NewSize = $cFile.Size
                    Type = $cFile.Type
                    IsBinary = $cFile.IsBinary
                    Encoding = $cFile.Encoding
                    LineEndings = $cFile.LineEndings
                }
                $modifiedList += $modObj
                if ($cFile.IsBinary) {
                    $binaryList += $cFile
                }
            }
        }
    }

    # Detect Added and Renamed
    $candidateAdded = @()
    foreach ($p in $currentMap.Keys) {
        if (-not $baselineMap.ContainsKey($p)) {
            $candidateAdded += $currentMap[$p]
        }
    }

    # Match Renamed / Moved files (Identical SHA-256 between Added and Deleted)
    $matchedDeletedPaths = @()
    foreach ($addedItem in $candidateAdded) {
        $foundRename = $false
        foreach ($delPath in $candidateDeleted.Keys) {
            if ($matchedDeletedPaths -contains $delPath) { continue }
            $delItem = $candidateDeleted[$delPath]
            if ($addedItem.Sha256 -eq $delItem.sha256) {
                # Renamed file!
                $renamedList += @{
                    OldPath = $delPath
                    NewPath = $addedItem.Path
                    Sha256 = $addedItem.Sha256
                    Size = $addedItem.Size
                    Type = $addedItem.Type
                }
                $matchedDeletedPaths += $delPath
                $foundRename = $true
                break
            }
        }
        if (-not $foundRename) {
            $addedList += $addedItem
            if ($addedItem.IsBinary) {
                $binaryList += $addedItem
            }
        }
    }

    # Unmatched deletes are true deletions
    foreach ($delPath in $candidateDeleted.Keys) {
        if (-not ($matchedDeletedPaths -contains $delPath)) {
            $deletedList += $candidateDeleted[$delPath]
        }
    }

    $totalChanges = $addedList.Count + $modifiedList.Count + $deletedList.Count + $renamedList.Count

    if ($totalChanges -eq 0) {
        Write-Host ""
        Write-Host "======================================================================" -ForegroundColor Green
        Write-Host "  [NO CHANGES DETECTED]" -ForegroundColor Green
        Write-Host "  The working directory is 100% identical to baseline '$parentSnapshotId'."
        Write-Host "  No delta package generated to prevent token waste in ChatGPT."
        Write-Host "======================================================================" -ForegroundColor Green
        return $null
    }

    Write-Host "      Changes Detected: $($addedList.Count) Added, $($modifiedList.Count) Modified, $($deletedList.Count) Deleted, $($renamedList.Count) Renamed." -ForegroundColor Yellow

    Write-Host "[4/6] Generating Git-style unified diffs (changes.patch)..." -ForegroundColor Cyan
    $isGitAvail = $GitMeta.Installed
    $patchBuilder = New-Object System.Text.StringBuilder

    # 1. Renamed files in patch
    foreach ($r in $renamedList) {
        [void]$patchBuilder.AppendLine("diff --git a/$($r.OldPath) b/$($r.NewPath)")
        [void]$patchBuilder.AppendLine("similarity index 100%")
        [void]$patchBuilder.AppendLine("rename from $($r.OldPath)")
        [void]$patchBuilder.AppendLine("rename to $($r.NewPath)")
        [void]$patchBuilder.AppendLine("")
    }

    # 2. Deleted files in patch
    foreach ($d in $deletedList) {
        $oldFileOnDisk = Join-Path $baselineFilesDir $d.path
        if ($d.is_binary) {
            [void]$patchBuilder.AppendLine("diff --git a/$($d.path) b/$($d.path)")
            [void]$patchBuilder.AppendLine("deleted file mode 100644")
            [void]$patchBuilder.AppendLine("Binary file a/$($d.path) has been deleted")
            [void]$patchBuilder.AppendLine("")
        }
        else {
            $diffBlock = Generate-FileUnifiedDiff -OldFilePath $oldFileOnDisk -NewFilePath "/dev/null" -RelativePath $d.path -OldSha256 $d.sha256 -NewSha256 "0000000" -IsGitAvailable $isGitAvail
            [void]$patchBuilder.AppendLine($diffBlock)
            [void]$patchBuilder.AppendLine("")
        }
    }

    # 3. Added files in patch
    foreach ($a in $addedList) {
        if ($a.IsBinary) {
            [void]$patchBuilder.AppendLine("diff --git a/$($a.Path) b/$($a.Path)")
            [void]$patchBuilder.AppendLine("new file mode 100644")
            [void]$patchBuilder.AppendLine("Binary file added: $($a.Path) (See changed_binary_files/)")
            [void]$patchBuilder.AppendLine("")
        }
        else {
            $diffBlock = Generate-FileUnifiedDiff -OldFilePath "/dev/null" -NewFilePath $a.FullPath -RelativePath $a.Path -OldSha256 "0000000" -NewSha256 $a.Sha256 -IsGitAvailable $isGitAvail
            [void]$patchBuilder.AppendLine($diffBlock)
            [void]$patchBuilder.AppendLine("")
        }
    }

    # 4. Modified files in patch
    foreach ($m in $modifiedList) {
        $oldFileOnDisk = Join-Path $baselineFilesDir $m.Path
        $newFileOnDisk = (Join-Path $RepoRoot $m.Path)

        if ($m.IsBinary) {
            [void]$patchBuilder.AppendLine("diff --git a/$($m.Path) b/$($m.Path)")
            [void]$patchBuilder.AppendLine("Binary files a/$($m.Path) and b/$($m.Path) differ")
            [void]$patchBuilder.AppendLine("")
        }
        else {
            $diffBlock = Generate-FileUnifiedDiff -OldFilePath $oldFileOnDisk -NewFilePath $newFileOnDisk -RelativePath $m.Path -OldSha256 $m.OldSha256 -NewSha256 $m.NewSha256 -IsGitAvailable $isGitAvail
            [void]$patchBuilder.AppendLine($diffBlock)
            [void]$patchBuilder.AppendLine("")
        }
    }

    $patchContent = $patchBuilder.ToString()

    Write-Host "[5/6] Building Delta Package Archive..." -ForegroundColor Cyan
    $dateFolder = Get-Date -Format "yyyyMMdd"
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $deltaSnapshotId = "DELTA_$timestamp"
    $outputDir = Join-Path $PackagerDir "Output\$dateFolder"
    if (-not (Test-Path $outputDir)) {
        [void](New-Item -ItemType Directory -Path $outputDir -Force)
    }

    $deltaZipPath = Join-Path $outputDir "$deltaSnapshotId.zip"
    if (Test-Path $deltaZipPath) {
        $deltaZipPath = Join-Path $outputDir "${deltaSnapshotId}_1.zip"
    }

    # Prepare Delta Manifest
    $deltaManifest = @{
        delta_snapshot_id = $deltaSnapshotId
        parent_snapshot_id = $parentSnapshotId
        created_at = [DateTime]::UtcNow.ToString("o")
        git_commit = $GitMeta.CommitHash
        git_branch = $GitMeta.Branch
        git_uncommitted_changes = $GitMeta.HasUncommitted
        changes_count = @{
            added = $addedList.Count
            modified = $modifiedList.Count
            deleted = $deletedList.Count
            renamed = $renamedList.Count
            binary_files = $binaryList.Count
            total = $totalChanges
        }
        changes = @()
    }

    foreach ($r in $renamedList) {
        $deltaManifest.changes += @{ status = "Renamed"; old_path = $r.OldPath; new_path = $r.NewPath; sha256 = $r.Sha256; size = $r.Size }
    }
    foreach ($a in $addedList) {
        $deltaManifest.changes += @{ status = "Added"; path = $a.Path; new_sha256 = $a.Sha256; size = $a.Size; is_binary = $a.IsBinary; encoding = $a.Encoding }
    }
    foreach ($m in $modifiedList) {
        $deltaManifest.changes += @{ status = "Modified"; path = $m.Path; old_sha256 = $m.OldSha256; new_sha256 = $m.NewSha256; old_size = $m.OldSize; new_size = $m.NewSize; is_binary = $m.IsBinary; encoding = $m.Encoding }
    }
    foreach ($d in $deletedList) {
        $deltaManifest.changes += @{ status = "Deleted"; path = $d.path; old_sha256 = $d.sha256; size = $d.size }
    }

    $deltaManifestJson = ConvertTo-Json $deltaManifest -Depth 5
    $changesSummaryMd = Generate-ChangesSummaryMd -DeltaSnapshotId $deltaSnapshotId -ParentSnapshotId $parentSnapshotId -GitMeta $GitMeta -AddedList $addedList -ModifiedList $modifiedList -DeletedList $deletedList -RenamedList $renamedList -BinaryList $binaryList
    $readmeChatGptMd = Generate-ReadmeForChatGpt -DeltaSnapshotId $deltaSnapshotId -ParentSnapshotId $parentSnapshotId

    # Create Delta ZIP
    $zipFileStream = [System.IO.File]::Open($deltaZipPath, [System.IO.FileMode]::CreateNew)
    $archive = New-Object System.IO.Compression.ZipArchive($zipFileStream, [System.IO.Compression.ZipArchiveMode]::Create)

    try {
        # README_FOR_CHATGPT.md
        $readmeEntry = $archive.CreateEntry("README_FOR_CHATGPT.md", [System.IO.Compression.CompressionLevel]::Optimal)
        $rStream = $readmeEntry.Open()
        $rBytes = [System.Text.Encoding]::UTF8.GetBytes($readmeChatGptMd)
        $rStream.Write($rBytes, 0, $rBytes.Length)
        $rStream.Close()

        # delta_manifest.json
        $mEntry = $archive.CreateEntry("delta_manifest.json", [System.IO.Compression.CompressionLevel]::Optimal)
        $mStream = $mEntry.Open()
        $mBytes = [System.Text.Encoding]::UTF8.GetBytes($deltaManifestJson)
        $mStream.Write($mBytes, 0, $mBytes.Length)
        $mStream.Close()

        # changes.patch
        $pEntry = $archive.CreateEntry("changes.patch", [System.IO.Compression.CompressionLevel]::Optimal)
        $pStream = $pEntry.Open()
        $pBytes = [System.Text.Encoding]::UTF8.GetBytes($patchContent)
        $pStream.Write($pBytes, 0, $pBytes.Length)
        $pStream.Close()

        # CHANGES_SUMMARY.md
        $sEntry = $archive.CreateEntry("CHANGES_SUMMARY.md", [System.IO.Compression.CompressionLevel]::Optimal)
        $sStream = $sEntry.Open()
        $sBytes = [System.Text.Encoding]::UTF8.GetBytes($changesSummaryMd)
        $sStream.Write($sBytes, 0, $sBytes.Length)
        $sStream.Close()

        # changed_binary_files/ (only if any binary changes exist)
        foreach ($binItem in $binaryList) {
            $binEntryName = "changed_binary_files/$($binItem.Path)"
            $bEntry = $archive.CreateEntry($binEntryName, [System.IO.Compression.CompressionLevel]::Optimal)
            $bStream = $bEntry.Open()
            $bBytes = [System.IO.File]::ReadAllBytes($binItem.FullPath)
            $bStream.Write($bBytes, 0, $bBytes.Length)
            $bStream.Close()
        }
    }
    finally {
        $archive.Dispose()
        $zipFileStream.Dispose()
    }

    # Verify Delta ZIP Integrity
    $testZip = [System.IO.Compression.ZipFile]::OpenRead($deltaZipPath)
    $deltaEntriesCount = $testZip.Entries.Count
    $testZip.Dispose()

    if ($deltaEntriesCount -lt 4) {
        throw "Delta ZIP verification failed: Expected at least 4 entries, found $deltaEntriesCount."
    }

    Write-Host "[6/6] Advancing local comparison baseline in State/..." -ForegroundColor Cyan

    # Construct new full snapshot state manifest
    $newSnapshotManifest = @{
        snapshot_id = $deltaSnapshotId
        mode = "Delta"
        parent_snapshot_id = $parentSnapshotId
        created_at = [DateTime]::UtcNow.ToString("o")
        git_commit = $GitMeta.CommitHash
        git_branch = $GitMeta.Branch
        git_uncommitted_changes = $GitMeta.HasUncommitted
        total_files = $currentMap.Count
        files = @()
    }

    foreach ($rel in ($currentMap.Keys | Sort-Object)) {
        $f = $currentMap[$rel]
        $newSnapshotManifest.files += @{
            path = $f.Path
            sha256 = $f.Sha256
            size = $f.Size
            type = $f.Type
            is_binary = $f.IsBinary
            encoding = $f.Encoding
            line_endings = $f.LineEndings
        }
    }

    # Update State/latest_snapshot.json
    $newManifestJson = ConvertTo-Json $newSnapshotManifest -Depth 5
    [System.IO.File]::WriteAllText($baselineManifestPath, $newManifestJson, [System.Text.Encoding]::UTF8)

    # Synchronize State/baseline_files/ mirror
    # Delete removed files
    foreach ($d in $deletedList) {
        $delTarget = Join-Path $baselineFilesDir $d.path
        if (Test-Path $delTarget) {
            Remove-Item -Path $delTarget -Force
        }
    }
    # Move renamed files
    foreach ($r in $renamedList) {
        $oldTarget = Join-Path $baselineFilesDir $r.OldPath
        $newTarget = Join-Path $baselineFilesDir $r.NewPath
        if (Test-Path $oldTarget) {
            $newParent = [System.IO.Path]::GetDirectoryName($newTarget)
            if (-not (Test-Path $newParent)) {
                [void](New-Item -ItemType Directory -Path $newParent -Force)
            }
            Move-Item -Path $oldTarget -Destination $newTarget -Force
        }
    }
    # Copy added and modified files
    foreach ($a in $addedList) {
        $destPath = Join-Path $baselineFilesDir $a.Path
        $destParent = [System.IO.Path]::GetDirectoryName($destPath)
        if (-not (Test-Path $destParent)) {
            [void](New-Item -ItemType Directory -Path $destParent -Force)
        }
        [System.IO.File]::Copy($a.FullPath, $destPath, $true)
    }
    foreach ($m in $modifiedList) {
        $destPath = Join-Path $baselineFilesDir $m.Path
        $destParent = [System.IO.Path]::GetDirectoryName($destPath)
        if (-not (Test-Path $destParent)) {
            [void](New-Item -ItemType Directory -Path $destParent -Force)
        }
        [System.IO.File]::Copy((Join-Path $RepoRoot $m.Path), $destPath, $true)
    }

    $deltaSize = (Get-Item $deltaZipPath).Length
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Green
    Write-Host "  [DELTA PACKAGE READY FOR CHATGPT]" -ForegroundColor Green
    Write-Host "  ZIP Location     : $deltaZipPath" -ForegroundColor Yellow
    Write-Host "  Parent Snapshot  : $parentSnapshotId"
    Write-Host "  Current Snapshot : $deltaSnapshotId"
    Write-Host "  Changes Contained: $totalChanges (Patches + Manifest + Summary)"
    Write-Host "  Package Size     : $([Math]::Round($deltaSize / 1KB, 2)) KB"
    Write-Host "======================================================================" -ForegroundColor Green

    return $deltaZipPath
}

# ==============================================================================
# MAIN ENTRY POINT
# ==============================================================================

try {
    $packagerDir = Get-PackagerRoot
    $repoRoot = Get-ProjectRepoRoot -ScriptDir $packagerDir

    if ([string]::IsNullOrEmpty($ConfigPath)) {
        $ConfigPath = Join-Path $packagerDir "pack-config.json"
    }

    $config = Load-PackConfig -Path $ConfigPath
    $gitMeta = Get-SafeGitMetadata -RepoRoot $repoRoot

    Write-Host "Repository Root  : $repoRoot" -ForegroundColor Gray
    Write-Host "Packager Tool    : $packagerDir" -ForegroundColor Gray
    Write-Host "Target Operation : $Mode" -ForegroundColor Gray
    Write-Host ""

    switch ($Mode) {
        "Full" {
            Invoke-FullPackage -RepoRoot $repoRoot -PackagerDir $packagerDir -Config $config -GitMeta $gitMeta -Verbose:$VerboseLog
        }
        "Delta" {
            Invoke-DeltaPackage -RepoRoot $repoRoot -PackagerDir $packagerDir -Config $config -GitMeta $gitMeta -Verbose:$VerboseLog
        }
        "Status" {
            $stateDir = Join-Path $packagerDir "State"
            $manifestPath = Join-Path $stateDir "latest_snapshot.json"
            if (Test-Path $manifestPath) {
                $raw = [System.IO.File]::ReadAllText($manifestPath, [System.Text.Encoding]::UTF8)
                $b = ConvertFrom-Json $raw
                Write-Host "Current Snapshot ID : $($b.snapshot_id)" -ForegroundColor Cyan
                Write-Host "Mode                : $($b.mode)" -ForegroundColor Cyan
                Write-Host "Created At          : $($b.created_at)" -ForegroundColor Cyan
                Write-Host "Tracked Files       : $($b.total_files)" -ForegroundColor Cyan
                Write-Host "Git Baseline Commit : $($b.git_commit)" -ForegroundColor Cyan
            }
            else {
                Write-Host "No baseline snapshot found in State/." -ForegroundColor Yellow
            }
        }
    }
}
catch {
    Write-Host ""
    Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
    Write-Host "  [PACKAGING ERROR] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Stack Trace: $($_.ScriptStackTrace)" -ForegroundColor DarkRed
    Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
    exit 1
}
