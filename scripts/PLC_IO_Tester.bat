@echo off
title PVA VPU-50 Delta AS332T PLC Digital I/O Testing Utility
cls
echo ====================================================================
echo   PVA SYSTEMS VPU-50 - DELTA AS332T-A DIGITAL I/O TESTER
echo   Target PLC: 192.168.1.5:502 (Modbus TCP)
echo ====================================================================
echo.
echo Select an option:
echo   [1] Show Live Digital I/O Status Matrix (Outputs Y0-Y15, Inputs X0-X15)
echo   [2] Turn ON Output 2 (Y0.2 - 3rd Output LED)
echo   [3] Turn OFF Output 2 (Y0.2)
echo   [4] Turn ON Output 3 (Y0.3 - 4th Output LED)
echo   [5] Turn OFF Output 3 (Y0.3)
echo   [6] Blink Output 2 (Y0.2) 5 times (Relay test)
echo   [7] Turn OFF ALL 16 Outputs (Emergency reset)
echo   [8] Open Interactive Terminal (Type numbers 0-15 to toggle)
echo   [9] Exit
echo.
set /p opt="Enter choice [1-9]: "

if "%opt%"=="1" (
    python "%~dp0\plc_io_control.py" --status
) else if "%opt%"=="2" (
    python "%~dp0\plc_io_control.py" --output 2 --state on
) else if "%opt%"=="3" (
    python "%~dp0\plc_io_control.py" --output 2 --state off
) else if "%opt%"=="4" (
    python "%~dp0\plc_io_control.py" --output 3 --state on
) else if "%opt%"=="5" (
    python "%~dp0\plc_io_control.py" --output 3 --state off
) else if "%opt%"=="6" (
    python "%~dp0\plc_io_control.py" --blink 2 --count 5 --interval 0.4
) else if "%opt%"=="7" (
    python "%~dp0\plc_io_control.py" --all-off
) else if "%opt%"=="8" (
    python "%~dp0\plc_io_control.py" --interactive
) else if "%opt%"=="9" (
    exit /b 0
) else (
    echo Invalid choice.
)

echo.
pause
