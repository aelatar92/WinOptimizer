@echo off
title WinOptimizer Tray Monitor
cd /d "%~dp0"

if not exist "Gui\TrayMonitor.ps1" (
    echo CRITICAL ERROR: Gui\TrayMonitor.ps1 is missing in %cd%
    pause
    exit
)

:: Read-only health monitoring, no admin needed. Runs detached in the
:: background - this window closes immediately, the tray icon stays.
start "" /B powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0Gui\TrayMonitor.ps1"
exit
