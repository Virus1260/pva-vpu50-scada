@echo off
setlocal enabledelayedexpansion
title PVA VPU-50 SCADA - Delta Packager for ChatGPT

cd /d "%~dp0"
echo ======================================================================
echo   PVA SYSTEMS VPU-50 SCADA - GIT-STYLE DELTA PACKAGER
echo   Mode: DELTA (Only Changes Since Last Package + Unified Patches)
echo ======================================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Pack-Project.ps1" -Mode Delta

set EXIT_CODE=%ERRORLEVEL%
echo.
if %EXIT_CODE% EQU 0 (
    echo [SUCCESS] Delta operation completed successfully.
) else (
    echo [ERROR] Delta operation failed or required action (Exit code: %EXIT_CODE%^).
)
echo.
echo Press any key to exit...
pause >nul
exit /b %EXIT_CODE%

