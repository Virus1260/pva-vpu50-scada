@echo off
title PVA Systems VPU-50 SCADA - Real-Time Web Dashboard
cls
echo ====================================================================
echo   PVA SYSTEMS VPU-50 INDUSTRIAL SCADA - WEB DASHBOARD LAUNCHER
echo   Target Delta PLC: 192.168.1.5:502 (via AS-FFTP01 or CPU port)
echo ====================================================================
echo.
echo Starting Industrial Web Server on http://localhost:3000 ...

start "" "http://localhost:3000"
node "%~dp0\standalone_server.js"

pause
