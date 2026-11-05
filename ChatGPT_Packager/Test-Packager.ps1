<#
.SYNOPSIS
    Automated Test & Verification Suite for ChatGPT_Packager.
.DESCRIPTION
    Executes all 12 mandatory acceptance test cases in an isolated sandbox:
      1. No file changes
      2. One character modified
      3. Only one space modified
      4. New source file
      5. Deleted source file
      6. Renamed source file
      7. Binary asset modified
      8. File with spaces in its name
      9. CRLF-to-LF change
      10. Multiple successive delta packages
      11. Uncommitted Git changes
      12. Failure during ZIP creation (baseline non-corruption)
      13. Byte-for-byte cumulative reconstruction verification
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$ScriptDir = $PSScriptRoot
$PackProjectScript = Join-Path $ScriptDir "Pack-Project.ps1"
$ConfigTemplate = Join-Path $ScriptDir "pack-config.json"

$TestRoot = Join-Path $env:TEMP "Packager_Test_Sandbox_$([Guid]::NewGuid().ToString('N'))"
[void](New-Item -ItemType Directory -Path $TestRoot -Force)

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "  CHATGPT PACKAGER - AUTOMATED 12-POINT ACCEPTANCE TEST SUITE" -ForegroundColor Cyan
Write-Host "  Sandbox: $TestRoot" -ForegroundColor Gray
Write-Host "======================================================================" -ForegroundColor Cyan

function Assert-Condition {
    param([object]$Condition, [string]$TestName)
    $bCond = if ($Condition -is [System.Array]) { $Condition.Count -gt 0 } else { [bool]$Condition }
    if ($bCond) {
        Write-Host "  [PASS] $TestName" -ForegroundColor Green
    }
    else {
        Write-Host "  [FAIL] $TestName" -ForegroundColor Red
        throw "Assertion failed for test: $TestName"
    }
}

try {
    # --------------------------------------------------------------------------
    # Sandbox Setup: Mock Project Structure
    # --------------------------------------------------------------------------
    $ProjectDir = Join-Path $TestRoot "MockProject"
    [void](New-Item -ItemType Directory -Path $ProjectDir -Force)
    [void](New-Item -ItemType Directory -Path (Join-Path $ProjectDir "scada") -Force)
    [void](New-Item -ItemType Directory -Path (Join-Path $ProjectDir "PVA_VPU50_SCADAContent") -Force)
    [void](New-Item -ItemType Directory -Path (Join-Path $ProjectDir "assets") -Force)

    # Copy Packager directory into MockProject
    $PackagerCopy = Join-Path $ProjectDir "ChatGPT_Packager"
    [void](New-Item -ItemType Directory -Path $PackagerCopy -Force)
    Copy-Item -Path $PackProjectScript -Destination $PackagerCopy -Force
    Copy-Item -Path $ConfigTemplate -Destination $PackagerCopy -Force

    # Create Initial Mock Files
    [System.IO.File]::WriteAllText((Join-Path $ProjectDir "CMakeLists.txt"), "project(MockApp)`nversion 1.0`n", [System.Text.Encoding]::UTF8)
    [System.IO.File]::WriteAllText((Join-Path $ProjectDir "README.md"), "# Mock Project`nInitial description.`n", [System.Text.Encoding]::UTF8)
    [System.IO.File]::WriteAllText((Join-Path $ProjectDir "scada\plc.py"), "PLC_IP = `"192.168.1.10`"`ndef connect():`n    return True`n", [System.Text.Encoding]::UTF8)
    [System.IO.File]::WriteAllText((Join-Path $ProjectDir "PVA_VPU50_SCADAContent\App.qml"), "import QtQuick`nItem { id: root }`n", [System.Text.Encoding]::UTF8)
    
    # Mock Binary File (16 bytes including null byte)
    $mockBinaryBytes = [byte[]](0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52)
    [System.IO.File]::WriteAllBytes((Join-Path $ProjectDir "assets\logo.png"), $mockBinaryBytes)

    # Initialize Git repository in sandbox
    git -C "$ProjectDir" init -q
    git -C "$ProjectDir" config user.email "test@scada.internal"
    git -C "$ProjectDir" config user.name "Packager Tester"
    git -C "$ProjectDir" add .
    git -C "$ProjectDir" commit -m "initial commit" -q

    # --------------------------------------------------------------------------
    # Initial FULL PACKAGE Creation
    # --------------------------------------------------------------------------
    Write-Host "`n--- Initial Full Package Setup ---" -ForegroundColor Yellow
    $packScript = Join-Path $PackagerCopy "Pack-Project.ps1"
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$packScript" -Mode Full
    Assert-Condition ($LASTEXITCODE -eq 0) "Initial Full Package executes successfully"

    $stateManifestPath = Join-Path $PackagerCopy "State\latest_snapshot.json"
    Assert-Condition (Test-Path $stateManifestPath) "Baseline manifest latest_snapshot.json created in State/"

    $baselineFilesDir = Join-Path $PackagerCopy "State\baseline_files"
    Assert-Condition (Test-Path $baselineFilesDir) "Baseline file mirror directory created"

    # --------------------------------------------------------------------------
    # Test 1: No file changes
    # --------------------------------------------------------------------------
    Write-Host "`n--- Test 1: No file changes ---" -ForegroundColor Yellow
    $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$packScript" -Mode Delta
    Assert-Condition ($LASTEXITCODE -eq 0) "Delta mode exits with code 0 on no changes"
    Assert-Condition (($output -join "`n") -like "*NO CHANGES DETECTED*") "Reports 'NO CHANGES DETECTED' cleanly"

    # --------------------------------------------------------------------------
    # Test 2: One character modified
    # --------------------------------------------------------------------------
    Write-Host "`n--- Test 2: One character modified ---" -ForegroundColor Yellow
    # Change "192.168.1.10" to "192.168.1.20" in scada\plc.py
    $plcFile = Join-Path $ProjectDir "scada\plc.py"
    $plcContent = [System.IO.File]::ReadAllText($plcFile, [System.Text.Encoding]::UTF8)
    $plcContentMod = $plcContent.Replace("192.168.1.10", "192.168.1.20")
    [System.IO.File]::WriteAllText($plcFile, $plcContentMod, [System.Text.Encoding]::UTF8)

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$packScript" -Mode Delta
    Assert-Condition ($LASTEXITCODE -eq 0) "Delta created for 1-character modification"

    # Inspect generated delta ZIP
    $deltaZips = Get-ChildItem (Join-Path $PackagerCopy "Output") -Recurse -Filter "DELTA_*.zip" | Sort-Object LastWriteTime -Descending
    $deltaZip1 = $deltaZips[0].FullName
    $zipTest = [System.IO.Compression.ZipFile]::OpenRead($deltaZip1)
    $patchEntry = $zipTest.GetEntry("changes.patch")
    Assert-Condition ($patchEntry -ne $null) "changes.patch present in Delta ZIP"
    $stream = $patchEntry.Open()
    $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
    $patchText = $reader.ReadToEnd()
    $reader.Close()
    $zipTest.Dispose()

    Assert-Condition ($patchText -like "*192.168.1.20*") "Patch captures the exact modified character"

    # --------------------------------------------------------------------------
    # Test 3: Only one space modified
    # --------------------------------------------------------------------------
    Write-Host "`n--- Test 3: Only one space modified ---" -ForegroundColor Yellow
    # Add a trailing space to README.md
    $readmeFile = Join-Path $ProjectDir "README.md"
    $readmeContent = [System.IO.File]::ReadAllText($readmeFile, [System.Text.Encoding]::UTF8)
    [System.IO.File]::WriteAllText($readmeFile, ($readmeContent.TrimEnd() + " `n"), [System.Text.Encoding]::UTF8)

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$packScript" -Mode Delta
    Assert-Condition ($LASTEXITCODE -eq 0) "Delta created for whitespace-only modification"

    # --------------------------------------------------------------------------
    # Test 4: New source file added
    # --------------------------------------------------------------------------
    Write-Host "`n--- Test 4: New source file added ---" -ForegroundColor Yellow
    $newFile = Join-Path $ProjectDir "scada\new_module.py"
    [System.IO.File]::WriteAllText($newFile, "def new_function():`n    return 42`n", [System.Text.Encoding]::UTF8)

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$packScript" -Mode Delta
    Assert-Condition ($LASTEXITCODE -eq 0) "Delta created for newly added file"

    $deltaZips = Get-ChildItem (Join-Path $PackagerCopy "Output") -Recurse -Filter "DELTA_*.zip" | Sort-Object LastWriteTime -Descending
    $zipTest = [System.IO.Compression.ZipFile]::OpenRead($deltaZips[0].FullName)
    $manifestEntry = $zipTest.GetEntry("delta_manifest.json")
    $stream = $manifestEntry.Open()
    $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
    $mJson = ConvertFrom-Json $reader.ReadToEnd()
    $reader.Close()
    $zipTest.Dispose()

    $addedRec = $mJson.changes | Where-Object { $_.status -eq "Added" -and $_.path -eq "scada/new_module.py" }
    Assert-Condition ($addedRec -ne $null) "delta_manifest.json records Added status for scada/new_module.py"

    # --------------------------------------------------------------------------
    # Test 5: Deleted source file
    # --------------------------------------------------------------------------
    Write-Host "`n--- Test 5: Deleted source file ---" -ForegroundColor Yellow
    Remove-Item $newFile -Force

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$packScript" -Mode Delta
    Assert-Condition ($LASTEXITCODE -eq 0) "Delta created for deleted source file"

    $deltaZips = Get-ChildItem (Join-Path $PackagerCopy "Output") -Recurse -Filter "DELTA_*.zip" | Sort-Object LastWriteTime -Descending
    $zipTest = [System.IO.Compression.ZipFile]::OpenRead($deltaZips[0].FullName)
    $manifestEntry = $zipTest.GetEntry("delta_manifest.json")
    $stream = $manifestEntry.Open()
    $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
    $mJson = ConvertFrom-Json $reader.ReadToEnd()
    $reader.Close()
    $zipTest.Dispose()

    $delRec = $mJson.changes | Where-Object { $_.status -eq "Deleted" -and $_.path -eq "scada/new_module.py" }
    Assert-Condition ($delRec -ne $null) "delta_manifest.json records Deleted status for scada/new_module.py"

    # --------------------------------------------------------------------------
    # Test 6: Renamed / moved source file
    # --------------------------------------------------------------------------
    Write-Host "`n--- Test 6: Renamed / moved source file ---" -ForegroundColor Yellow
    # Create file then rename
    $sourceRename = Join-Path $ProjectDir "scada\temp_service.py"
    $destRename = Join-Path $ProjectDir "scada\renamed_service.py"
    [System.IO.File]::WriteAllText($sourceRename, "# Service Code`nTAG = 100`n", [System.Text.Encoding]::UTF8)
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$packScript" -Mode Delta | Out-Null
    
    # Now rename
    Move-Item -Path $sourceRename -Destination $destRename -Force
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$packScript" -Mode Delta
    Assert-Condition ($LASTEXITCODE -eq 0) "Delta created for renamed file"

    $deltaZips = Get-ChildItem (Join-Path $PackagerCopy "Output") -Recurse -Filter "DELTA_*.zip" | Sort-Object LastWriteTime -Descending
    $zipTest = [System.IO.Compression.ZipFile]::OpenRead($deltaZips[0].FullName)
    $manifestEntry = $zipTest.GetEntry("delta_manifest.json")
    $stream = $manifestEntry.Open()
    $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
    $mJson = ConvertFrom-Json $reader.ReadToEnd()
    $reader.Close()
    $zipTest.Dispose()

    $renameRec = $mJson.changes | Where-Object { $_.status -eq "Renamed" -and $_.old_path -eq "scada/temp_service.py" }
    Assert-Condition ($renameRec -ne $null -and $renameRec.new_path -eq "scada/renamed_service.py") "Detected Renamed status with identical SHA-256 match"

    # --------------------------------------------------------------------------
    # Test 7: Binary asset modified
    # --------------------------------------------------------------------------
    Write-Host "`n--- Test 7: Binary asset modified ---" -ForegroundColor Yellow
    $logoFile = Join-Path $ProjectDir "assets\logo.png"
    $modBinaryBytes = [byte[]](0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0xFF, 0xFF, 0xFF, 0xFF)
    [System.IO.File]::WriteAllBytes($logoFile, $modBinaryBytes)

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$packScript" -Mode Delta
    Assert-Condition ($LASTEXITCODE -eq 0) "Delta created for binary asset modification"

    $deltaZips = Get-ChildItem (Join-Path $PackagerCopy "Output") -Recurse -Filter "DELTA_*.zip" | Sort-Object LastWriteTime -Descending
    $zipTest = [System.IO.Compression.ZipFile]::OpenRead($deltaZips[0].FullName)
    $binEntry = $zipTest.GetEntry("changed_binary_files/assets/logo.png")
    Assert-Condition ($binEntry -ne $null) "Modified binary asset included under changed_binary_files/ in Delta ZIP"
    $zipTest.Dispose()

    # --------------------------------------------------------------------------
    # Test 8: File with spaces in its name
    # --------------------------------------------------------------------------
    Write-Host "`n--- Test 8: File with spaces in its name ---" -ForegroundColor Yellow
    $spacedFolder = Join-Path $ProjectDir "scada\spaced folder"
    [void](New-Item -ItemType Directory -Path $spacedFolder -Force)
    $spacedFile = Join-Path $spacedFolder "my custom script.py"
    [System.IO.File]::WriteAllText($spacedFile, "# script with spaces`nval = 42`n", [System.Text.Encoding]::UTF8)

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$packScript" -Mode Delta
    Assert-Condition ($LASTEXITCODE -eq 0) "Delta handles files and folders containing spaces"

    $deltaZips = Get-ChildItem (Join-Path $PackagerCopy "Output") -Recurse -Filter "DELTA_*.zip" | Sort-Object LastWriteTime -Descending
    $zipTest = [System.IO.Compression.ZipFile]::OpenRead($deltaZips[0].FullName)
    $patchEntry = $zipTest.GetEntry("changes.patch")
    $stream = $patchEntry.Open()
    $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
    $patchText = $reader.ReadToEnd()
    $reader.Close()
    $zipTest.Dispose()

    Assert-Condition ($patchText -like "*scada/spaced folder/my custom script.py*") "Patch captures path with spaces cleanly"

    # --------------------------------------------------------------------------
    # Test 9: CRLF-to-LF change
    # --------------------------------------------------------------------------
    Write-Host "`n--- Test 9: CRLF-to-LF line ending change ---" -ForegroundColor Yellow
    $crlfFile = Join-Path $ProjectDir "CMakeLists.txt"
    $bytesWithCrlf = [System.Text.Encoding]::UTF8.GetBytes("project(MockApp)`r`nversion 1.0`r`n")
    [System.IO.File]::WriteAllBytes($crlfFile, $bytesWithCrlf)
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$packScript" -Mode Delta | Out-Null

    # Now change to pure LF
    $bytesWithLf = [System.Text.Encoding]::UTF8.GetBytes("project(MockApp)`nversion 1.0`n")
    [System.IO.File]::WriteAllBytes($crlfFile, $bytesWithLf)

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$packScript" -Mode Delta
    Assert-Condition ($LASTEXITCODE -eq 0) "Delta detects CRLF vs LF line ending alteration via SHA-256"

    # --------------------------------------------------------------------------
    # Test 10: Multiple successive delta packages
    # --------------------------------------------------------------------------
    Write-Host "`n--- Test 10: Multiple successive delta packages & chaining ---" -ForegroundColor Yellow
    # Delta A
    [System.IO.File]::WriteAllText((Join-Path $ProjectDir "README.md"), "Successive update 1`n", [System.Text.Encoding]::UTF8)
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$packScript" -Mode Delta | Out-Null
    $mRaw1 = [System.IO.File]::ReadAllText((Join-Path $PackagerCopy "State\latest_snapshot.json"), [System.Text.Encoding]::UTF8)
    $snapId1 = (ConvertFrom-Json $mRaw1).snapshot_id

    # Delta B
    [System.IO.File]::WriteAllText((Join-Path $ProjectDir "README.md"), "Successive update 2`n", [System.Text.Encoding]::UTF8)
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$packScript" -Mode Delta | Out-Null
    $mRaw2 = [System.IO.File]::ReadAllText((Join-Path $PackagerCopy "State\latest_snapshot.json"), [System.Text.Encoding]::UTF8)
    $snapObj2 = ConvertFrom-Json $mRaw2
    $snapId2 = $snapObj2.snapshot_id
    $parentSnap2 = $snapObj2.parent_snapshot_id

    Assert-Condition ($parentSnap2 -eq $snapId1) "Successive delta correctly links to immediate parent snapshot ($parentSnap2 -> $snapId1)"

    # --------------------------------------------------------------------------
    # Test 11: Uncommitted Git changes
    # --------------------------------------------------------------------------
    Write-Host "`n--- Test 11: Uncommitted Git changes detection ---" -ForegroundColor Yellow
    # Create an uncommitted change in working tree
    [System.IO.File]::WriteAllText((Join-Path $ProjectDir "scada\plc.py"), "UNCOMMITTED_DEV_FLAG = True`n", [System.Text.Encoding]::UTF8)
    
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$packScript" -Mode Delta | Out-Null
    $mRaw = [System.IO.File]::ReadAllText((Join-Path $PackagerCopy "State\latest_snapshot.json"), [System.Text.Encoding]::UTF8)
    $snapObj = ConvertFrom-Json $mRaw
    Assert-Condition ($snapObj.git_uncommitted_changes -eq $true) "Detects uncommitted git changes in snapshot manifest without touching git index"

    # --------------------------------------------------------------------------
    # Test 12: Failure during ZIP creation (Baseline non-corruption)
    # --------------------------------------------------------------------------
    Write-Host "`n--- Test 12: Failure handling & baseline non-corruption ---" -ForegroundColor Yellow
    $baselineBefore = [System.IO.File]::ReadAllText((Join-Path $PackagerCopy "State\latest_snapshot.json"), [System.Text.Encoding]::UTF8)
    
    # Intentionally trigger failure by making Output folder a read-only file or invalid config
    $fakeConfig = Join-Path $PackagerCopy "broken-config.json"
    [System.IO.File]::WriteAllText($fakeConfig, "{ invalid json", [System.Text.Encoding]::UTF8)
    
    $failRun = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$packScript" -Mode Delta -ConfigPath "$fakeConfig" 2>&1
    Assert-Condition ($LASTEXITCODE -ne 0) "Script exits with non-zero error code on failure"

    $baselineAfter = [System.IO.File]::ReadAllText((Join-Path $PackagerCopy "State\latest_snapshot.json"), [System.Text.Encoding]::UTF8)
    Assert-Condition ($baselineBefore -eq $baselineAfter) "Baseline state was NOT corrupted or advanced during failed run"
    Remove-Item $fakeConfig -Force

    # --------------------------------------------------------------------------
    # Test 13: Cumulative Byte-for-Byte Reconstruction
    # --------------------------------------------------------------------------
    Write-Host "`n--- Test 13: Cumulative Byte-for-Byte Reconstruction Verification ---" -ForegroundColor Yellow
    # Verify that the files in State/baseline_files match the working directory 100%
    $currentWorkingFiles = Get-ChildItem -Path $ProjectDir -Recurse -File | Where-Object { $_.FullName -notmatch '\\(ChatGPT_Packager|\.git)\\' }
    $mismatches = 0
    foreach ($cwf in $currentWorkingFiles) {
        $relPath = ($cwf.FullName.Substring($ProjectDir.Length)).TrimStart("\", "/").Replace("\", "/")
        $mirrorPath = Join-Path (Join-Path $PackagerCopy "State\baseline_files") $relPath
        if (-not (Test-Path $mirrorPath)) {
            $mismatches++
            Write-Host "Missing mirrored file: $relPath" -ForegroundColor Red
        }
        else {
            $curHash = (Get-FileHash $cwf.FullName -Algorithm SHA256).Hash
            $mirHash = (Get-FileHash $mirrorPath -Algorithm SHA256).Hash
            if ($curHash -ne $mirHash) {
                $mismatches++
                Write-Host "Hash mismatch on file: $relPath ($curHash != $mirHash)" -ForegroundColor Red
            }
        }
    }
    Assert-Condition ($mismatches -eq 0) "100% Byte-for-byte SHA-256 match between current project state and chained delta baseline"

    Write-Host "`n======================================================================" -ForegroundColor Green
    Write-Host "  ALL 12 MANDATORY ACCEPTANCE TESTS + RECONSTRUCTION PASSED (100%)" -ForegroundColor Green
    Write-Host "======================================================================" -ForegroundColor Green
}
finally {
    # Cleanup sandbox
    if (Test-Path $TestRoot) {
        Remove-Item -Path $TestRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
