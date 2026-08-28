# WinOptimizer Uninstaller - removes Start Menu shortcuts, the Desktop
# shortcut if present, and the "Add or Remove Programs" registry entry.
# Runs from inside the install folder, so it deliberately does NOT
# delete that folder itself (can't remove a directory a running script
# lives in, and it may contain Data\exports, logs\, and reports\ the
# user created - safer to say so and let them delete it once they've
# looked, than to silently destroy it).
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"") -Verb RunAs
    exit
}

$InstallDir = $PSScriptRoot

Write-Host "This removes WinOptimizer's Start Menu/Desktop shortcuts and its Add/Remove Programs entry." -ForegroundColor Yellow
Write-Host "It will NOT delete $InstallDir itself (your logs, reports, and exports live there)." -ForegroundColor Yellow
$confirm = Read-Host 'Type YES to continue'
if ($confirm -ne 'YES') {
    Write-Host 'Cancelled.' -ForegroundColor Gray
    exit
}

$startMenuDir = Join-Path ([Environment]::GetFolderPath('CommonPrograms')) 'WinOptimizer'
Remove-Item -Path $startMenuDir -Recurse -Force -ErrorAction SilentlyContinue

$desktopShortcut = Join-Path ([Environment]::GetFolderPath('CommonDesktopDirectory')) 'WinOptimizer.lnk'
Remove-Item -Path $desktopShortcut -Force -ErrorAction SilentlyContinue

Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\WinOptimizer' -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`nShortcuts and the Add/Remove Programs entry are removed." -ForegroundColor Green
Write-Host "To finish, delete this folder yourself once you've grabbed anything you want to keep from it: $InstallDir" -ForegroundColor Cyan
Read-Host 'Press Enter to exit'
