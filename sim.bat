@echo off
REM =========================================================================
REM PVA Systems VPU-50 SCADA – Local Builder & Deployment Simulator Launcher
REM =========================================================================
SETLOCAL

IF "%1"=="" (
    python scada_deploy_simulator.py --all
    GOTO :EOF
)

IF "%1"=="serve" (
    python scada_deploy_simulator.py --serve --port 3000
    GOTO :EOF
)

IF "%1"=="probe" (
    python scada_deploy_simulator.py --probe
    GOTO :EOF
)

IF "%1"=="hook" (
    python scada_deploy_simulator.py --install-hook
    GOTO :EOF
)

IF "%1"=="stage" (
    python scada_deploy_simulator.py --auto-stage
    GOTO :EOF
)

IF "%1"=="test" (
    python scada_deploy_simulator.py --test
    GOTO :EOF
)

python scada_deploy_simulator.py %*

ENDLOCAL
