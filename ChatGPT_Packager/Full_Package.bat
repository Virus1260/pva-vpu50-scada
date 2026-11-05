@echo off
setlocal enabledelayedexpansion
title PVA VPU-50 SCADA - Full Source Packager for ChatGPT

cd /d "%~dp0"
echo ======================================================================
echo   PVA SYSTEMS VPU-50 SCADA - FULL SOURCE CODE PACKAGER
echo   Mode: FULL (All Project Source Files + Manifest + Project Context)
echo ======================================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Pack-Project.ps1" -Mode Full

set EXIT_CODE=%ERRORLEVEL%
echo.
if %EXIT_CODE% EQU 0 (
    echo [SUCCESS] Full package created and validated successfully.
) else (
    echo [ERROR] Packaging failed with exit code %EXIT_CODE%.
)
echo.
echo Press any key to exit...
pause >nul
exit /b %EXIT_CODE%

