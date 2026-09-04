# =========================================================================
# PVA Systems VPU-50 SCADA – PowerShell Simulator Launcher
# =========================================================================
param(
    [switch]$All,
    [switch]$Serve,
    [switch]$Probe,
    [switch]$InstallHook,
    [switch]$AutoStage,
    [switch]$Test,
    [int]$Port = 3000
)

$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($Serve) {
    python "$PSScriptRoot\scada_deploy_simulator.py" --serve --port $Port
} elseif ($Probe) {
    python "$PSScriptRoot\scada_deploy_simulator.py" --probe --port $Port
} elseif ($InstallHook) {
    python "$PSScriptRoot\scada_deploy_simulator.py" --install-hook
} elseif ($AutoStage) {
    python "$PSScriptRoot\scada_deploy_simulator.py" --auto-stage
} elseif ($Test) {
    python "$PSScriptRoot\scada_deploy_simulator.py" --test
} else {
    python "$PSScriptRoot\scada_deploy_simulator.py" --all
}
