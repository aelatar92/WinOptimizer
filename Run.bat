@echo off
title WinOptimizer Launcher

reg add "HKCU\Console\WinOptimizer Launcher" /v "FaceName" /t REG_SZ /d "Consolas" /f >nul 2>&1
reg add "HKCU\Console\WinOptimizer Launcher" /v "FontSize" /t REG_DWORD /d 1179648 /f >nul 2>&1
reg add "HKCU\Console\WinOptimizer Launcher" /v "FontFamily" /t REG_DWORD /d 54 /f >nul 2>&1
reg add "HKCU\Console\WinOptimizer Launcher" /v "WindowSize" /t REG_DWORD /d 2621560 /f >nul 2>&1
reg add "HKCU\Console\WinOptimizer Launcher" /v "CodePage" /t REG_DWORD /d 65001 /f >nul 2>&1

chcp 65001 >nul
cd /d "%~dp0"

net session >nul 2>&1
if %errorLevel% == 0 (
    goto :runScript
) else (
    goto :elevate
)

:elevate
cls
echo ====================================================
echo        WINOPTIMIZER - ELEVATION REQUIRED
echo ====================================================
echo [!] Requesting Administrator privileges...
echo [!] Please click "Yes" on the UAC prompt to continue.
echo.
powershell -Command "Start-Process '%~f0' -Verb RunAs"
exit

:runScript
cls
cd /d "%~dp0"

if not exist "Main.ps1" (
    echo CRITICAL ERROR: Main.ps1 is missing in %cd%
    pause
    exit
)

:: v2.2+ : You can also use the module way:
:: powershell -NoProfile -ExecutionPolicy Bypass -Command "Import-Module .\WinOptimizer.psd1 -Force; Start-WinOptimizer"

:: Classic console only (stable). For Windows Terminal use Run-WT.bat instead.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Main.ps1"

if %errorLevel% neq 0 (
    echo.
    echo PowerShell exited with code: %errorLevel%
    pause
)
exit
