@echo off
:: WinOptimizer via Windows Terminal (optional)
cd /d "%~dp0"

where wt >nul 2>&1
if %errorLevel% neq 0 (
    echo Windows Terminal not found. Use Run.bat instead.
    pause
    exit /b 1
)

if not exist "Main.ps1" (
    echo Main.ps1 not found in %cd%
    pause
    exit /b 1
)

:: Correct wt syntax: -d directory only, then the command line (no --title mixed with -d)
wt -d "%CD%" powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -File "%CD%\Main.ps1"
exit /b %errorLevel%
