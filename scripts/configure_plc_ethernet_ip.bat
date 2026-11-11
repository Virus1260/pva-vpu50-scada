@echo off
:: ============================================================================
:: Delta AS332T PLC - 1-Click Ethernet Adapter IP Configuration & Route Setup
:: Automatically requests Administrator elevation if not already elevated.
:: ============================================================================

setlocal enabledelayedexpansion

:: Check for Administrator privileges
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Requesting Administrator privileges to configure Ethernet adapter...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

title Delta AS332T PLC Ethernet Setup

echo ============================================================================
echo   DELTA AS332T PLC ETHERNET ADAPTER IP CONFIGURATION
echo ============================================================================
echo.

echo [1/3] Setting Static IP on adapter 'Ethernet'...
echo       IP Address  : 192.168.1.50
echo       Subnet Mask : 255.255.255.0
netsh interface ipv4 set address name="Ethernet" static 192.168.1.50 255.255.255.0

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to set IP on adapter 'Ethernet'.
    echo Please verify adapter name in 'ncpa.cpl'.
    pause
    exit /b 1
)
echo [OK] Static IP 192.168.1.50 assigned successfully to Ethernet.
echo.

echo [2/3] Adding high-priority route for Delta PLC (192.168.1.5)...
route delete 192.168.1.5 >nul 2>&1
route add 192.168.1.5 mask 255.255.255.255 192.168.1.50 metric 1 >nul 2>&1
echo [OK] Route established (prioritized over Wi-Fi).
echo.

echo [3/3] Testing Ping to Delta AS332T PLC (192.168.1.5)...
ping -n 3 192.168.1.5

echo.
echo ============================================================================
echo Configuration complete! You can now test live Modbus TCP communication.
echo ============================================================================
echo.
pause

