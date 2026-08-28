@echo off
title WinOptimizer GUI Launcher
cd /d "%~dp0"

if not exist "Gui\MainWindow.ps1" (
    echo CRITICAL ERROR: Gui\MainWindow.ps1 is missing in %cd%
    pause
    exit
)

:: The GUI (Gui\MainWindow.ps1) handles its own admin elevation prompt.
:: -WindowStyle Hidden keeps the console host out of the way of the WPF window.
powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0Gui\MainWindow.ps1"

if %errorLevel% neq 0 (
    echo.
    echo PowerShell exited with code: %errorLevel%
    pause
)
exit
