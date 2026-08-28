# WinOptimizer Installer
# Copies the app to a proper install location, creates Start Menu (and
# optionally Desktop) shortcuts, and registers an uninstall entry so it
# shows up in Windows' "Add or Remove Programs". Run.bat/RunGui.bat
# remain fully usable straight from an extracted ZIP without this -
# this is for anyone who wants WinOptimizer installed like a normal app.
[CmdletBinding()]
param(
    [string]$InstallDir = "$env:ProgramFiles\WinOptimizer",
    [switch]$DesktopShortcut
)

$ErrorActionPreference = 'Stop'

$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Host 'Administrator rights required. Re-launching elevated...' -ForegroundColor Yellow
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-InstallDir', "`"$InstallDir`"")
    if ($DesktopShortcut) { $argList += '-DesktopShortcut' }
    Start-Process -FilePath 'powershell.exe' -ArgumentList $argList -Verb RunAs
    exit
}

$SourceDir = $PSScriptRoot
$configPath = Join-Path $SourceDir 'config.json'
if (-not (Test-Path $configPath)) {
    Write-Host "CRITICAL ERROR: config.json not found next to Install.ps1 (looked in $SourceDir). Run this from the extracted WinOptimizer folder." -ForegroundColor Red
    Read-Host 'Press Enter to exit'
    exit 1
}
$version = (Get-Content $configPath -Raw | ConvertFrom-Json).version

Write-Host "Installing WinOptimizer v$version to $InstallDir ..." -ForegroundColor Cyan

if (-not (Test-Path $InstallDir)) { New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null }

$filesToCopy = @('Main.ps1', 'Run.bat', 'Run-WT.bat', 'RunGui.bat', 'RunTray.bat', 'config.json', 'README.md', 'Uninstall.ps1')
$dirsToCopy = @('Lib', 'Modules', 'Gui')

foreach ($f in $filesToCopy) {
    $src = Join-Path $SourceDir $f
    if (Test-Path $src) { Copy-Item -Path $src -Destination $InstallDir -Force }
}
foreach ($d in $dirsToCopy) {
    $src = Join-Path $SourceDir $d
    if (Test-Path $src) { Copy-Item -Path $src -Destination $InstallDir -Recurse -Force }
}

Write-Host 'Files copied. Creating shortcuts...' -ForegroundColor Cyan

$startMenuDir = Join-Path ([Environment]::GetFolderPath('CommonPrograms')) 'WinOptimizer'
if (-not (Test-Path $startMenuDir)) { New-Item -Path $startMenuDir -ItemType Directory -Force | Out-Null }

$shell = New-Object -ComObject WScript.Shell

$shortcut = $shell.CreateShortcut((Join-Path $startMenuDir 'WinOptimizer.lnk'))
$shortcut.TargetPath = Join-Path $InstallDir 'Run.bat'
$shortcut.WorkingDirectory = $InstallDir
$shortcut.IconLocation = 'shell32.dll,21'
$shortcut.Description = 'WinOptimizer - Windows maintenance toolkit'
$shortcut.Save()

$guiShortcut = $shell.CreateShortcut((Join-Path $startMenuDir 'WinOptimizer (GUI).lnk'))
$guiShortcut.TargetPath = Join-Path $InstallDir 'RunGui.bat'
$guiShortcut.WorkingDirectory = $InstallDir
$guiShortcut.IconLocation = 'shell32.dll,21'
$guiShortcut.Description = 'WinOptimizer - graphical launcher'
$guiShortcut.Save()

$uninstallShortcut = $shell.CreateShortcut((Join-Path $startMenuDir 'Uninstall WinOptimizer.lnk'))
$uninstallShortcut.TargetPath = 'powershell.exe'
$uninstallShortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$(Join-Path $InstallDir 'Uninstall.ps1')`""
$uninstallShortcut.WorkingDirectory = $InstallDir
$uninstallShortcut.Save()

if ($DesktopShortcut) {
    $desktopShortcut = $shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('CommonDesktopDirectory')) 'WinOptimizer.lnk'))
    $desktopShortcut.TargetPath = Join-Path $InstallDir 'Run.bat'
    $desktopShortcut.WorkingDirectory = $InstallDir
    $desktopShortcut.IconLocation = 'shell32.dll,21'
    $desktopShortcut.Save()
}

Write-Host 'Registering with Add/Remove Programs...' -ForegroundColor Cyan

$sizeKB = [int]((Get-ChildItem $InstallDir -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1KB)
$uninstallKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\WinOptimizer'
New-Item -Path $uninstallKey -Force | Out-Null
Set-ItemProperty -Path $uninstallKey -Name 'DisplayName' -Value 'WinOptimizer'
Set-ItemProperty -Path $uninstallKey -Name 'DisplayVersion' -Value $version
Set-ItemProperty -Path $uninstallKey -Name 'Publisher' -Value 'aelatar92'
Set-ItemProperty -Path $uninstallKey -Name 'InstallLocation' -Value $InstallDir
Set-ItemProperty -Path $uninstallKey -Name 'UninstallString' -Value "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$(Join-Path $InstallDir 'Uninstall.ps1')`""
Set-ItemProperty -Path $uninstallKey -Name 'NoModify' -Value 1 -Type DWord
Set-ItemProperty -Path $uninstallKey -Name 'NoRepair' -Value 1 -Type DWord
Set-ItemProperty -Path $uninstallKey -Name 'EstimatedSize' -Value $sizeKB -Type DWord

Write-Host "`nInstalled. Launch from Start Menu -> WinOptimizer, or run: $InstallDir\Run.bat" -ForegroundColor Green
Write-Host 'It will also show up in Settings -> Apps -> Installed apps for uninstalling.' -ForegroundColor Gray
Read-Host 'Press Enter to exit'
