# WinOptimizer Main v2.0.0
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ConsoleFontCode = @"
using System;
using System.Runtime.InteropServices;
public class WinOptimizerUI {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct CONSOLE_FONT_INFO_EX {
        public uint cbSize; public uint nFont;
        public short dwFontSizeX; public short dwFontSizeY;
        public int FontFamily; public int FontWeight;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string FaceName;
    }
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool SetCurrentConsoleFontEx(IntPtr h, bool b, ref CONSOLE_FONT_INFO_EX f);
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetStdHandle(int n);
    public static void ApplyPremiumFont(string fontName, short fontSizeY) {
        IntPtr hConsole = GetStdHandle(-11);
        CONSOLE_FONT_INFO_EX cfi = new CONSOLE_FONT_INFO_EX();
        cfi.cbSize = (uint)Marshal.SizeOf(cfi);
        cfi.dwFontSizeY = fontSizeY; cfi.FontFamily = 54; cfi.FontWeight = 400; cfi.FaceName = fontName;
        SetCurrentConsoleFontEx(hConsole, false, ref cfi);
    }
}
"@
try {
    Add-Type -TypeDefinition $ConsoleFontCode -ErrorAction SilentlyContinue
    [WinOptimizerUI]::ApplyPremiumFont("Consolas", 18)
    $Host.UI.RawUI.BufferSize = @{ Width = 120; Height = 1000 }
    $Host.UI.RawUI.WindowSize = @{ Width = 120; Height = 35 }
} catch {}

Clear-Host

$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ($ScriptDir -eq '') { $ScriptDir = '.' }

. (Join-Path $ScriptDir 'Lib\Common.ps1')
Initialize-WinOpt -Root $ScriptDir

if (-not $IsAdmin) {
    Write-Host (T 'admin_required') -ForegroundColor Red
    Read-Host (T 'press_enter')
    Exit
}

Test-WinOptStartupRequirements

function Show-Main-Menu {
    Clear-Host
    Write-Host "========================================================================================" -ForegroundColor Cyan
    Write-Host "  WINDOWS SYSTEM OPTIMIZER v$script:WinOptVersion" -ForegroundColor Yellow
    Write-Host "  Mode: $script:WinOptMode" -ForegroundColor Gray
    Write-Host "========================================================================================" -ForegroundColor Cyan
    Write-Host "  [1]  Safe OS Optimization & Temp Cleanup" -ForegroundColor White
    Write-Host "  [2]  Disk Tools (SFC, DISM, chkdsk, Trim)" -ForegroundColor White
    Write-Host "  [3]  Advanced & Gaming Tweaks" -ForegroundColor White
    Write-Host "  [4]  Drivers & System Repair" -ForegroundColor White
    Write-Host "  [5]  Winget Apps Installer" -ForegroundColor White
    Write-Host "  [6]  Security & Restore Point" -ForegroundColor White
    Write-Host "  [7]  Smart Diagnostics & Health Score" -ForegroundColor White
    Write-Host "  [8]  Startup Programs Manager" -ForegroundColor White
    Write-Host "  [9]  Windows Services Manager" -ForegroundColor White
    Write-Host "  [10] Advanced Cleanup (Recycle, Delivery)" -ForegroundColor White
    Write-Host "  [11] Network Tools (Ping, DNS, Speed)" -ForegroundColor White
    Write-Host "  [12] Backup & Export" -ForegroundColor White
    Write-Host "  [13] Battery Health Report" -ForegroundColor White
    Write-Host "  [14] Task Scheduler" -ForegroundColor White
    Write-Host "  [15] Settings (Mode, Rollback, Logs)" -ForegroundColor White
    Write-Host "  [16] Help Guide" -ForegroundColor White
    Write-Host "  [17] Exit" -ForegroundColor Red
    Write-Host "----------------------------------------------------------------------------------------" -ForegroundColor DarkGray
}

function Show-Help-Guide {
    Clear-Host
    Write-Host "Modules 1-7: core tools. 8-14: startup, services, cleanup, network, backup, battery, scheduler." -ForegroundColor Cyan
    Write-Host "15: settings and rollback. Beginner mode limits menu items. Logs in logs\ folder." -ForegroundColor Gray
    Wait-WinOptEnter
}

$ModuleMap = @{
    '1'  = @{ Path = 'Modules\1_OptimizeOS.ps1'; Num = 1 }
    '2'  = @{ Path = 'Modules\2_DiskTools.ps1'; Num = 2 }
    '3'  = @{ Path = 'Modules\3_AdvancedTools.ps1'; Num = 3 }
    '4'  = @{ Path = 'Modules\4_DriversRepair.ps1'; Num = 4 }
    '5'  = @{ Path = 'Modules\5_SilentInstaller.ps1'; Num = 5 }
    '6'  = @{ Path = 'Modules\6_SecurityBackup.ps1'; Num = 6 }
    '7'  = @{ Path = 'Modules\7_AIDiagnostics.ps1'; Num = 7 }
    '8'  = @{ Path = 'Modules\8_StartupManager.ps1'; Num = 8 }
    '9'  = @{ Path = 'Modules\9_WindowsServices.ps1'; Num = 9 }
    '10' = @{ Path = 'Modules\10_AdvancedCleanup.ps1'; Num = 10 }
    '11' = @{ Path = 'Modules\11_NetworkTools.ps1'; Num = 11 }
    '12' = @{ Path = 'Modules\12_BackupExport.ps1'; Num = 12 }
    '13' = @{ Path = 'Modules\13_BatteryHealth.ps1'; Num = 13 }
    '14' = @{ Path = 'Modules\14_Scheduler.ps1'; Num = 14 }
    '15' = @{ Path = 'Modules\15_Settings.ps1'; Num = 15 }
}

$menuItems = @(1..17)
if ($script:WinOptMode -eq 'beginner') {
    $menuItems = @($script:WinOptConfig.beginnerAllowedModules)
}

do {
    Show-Main-Menu
    if ($script:WinOptMode -eq 'beginner') {
        Write-Host "  (Beginner mode: options $($menuItems -join ', ') only)" -ForegroundColor DarkGray
    }
    $MainChoice = Read-Host 'Select option (1-17)'

    if ($MainChoice -eq '16') { Show-Help-Guide; continue }
    if ($MainChoice -eq '17') {
        Write-Host "`nWinOptimizer v$script:WinOptVersion - Bye!" -ForegroundColor Green
        Write-WinOptLog 'Application exit'
        Start-Sleep -Seconds 1
        break
    }

    if (-not $ModuleMap.ContainsKey($MainChoice)) {
        Write-Host (T 'invalid_choice') -ForegroundColor Yellow
        Start-Sleep -Seconds 1
        continue
    }

    $info = $ModuleMap[$MainChoice]
    if (-not (Test-WinOptModuleAllowed -ModuleNumber $info.Num)) {
        Write-Host (T 'module_blocked') -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        continue
    }

    $TargetModulePath = Join-Path $ScriptDir $info.Path
    Write-Host "`n[+] $TargetModulePath" -ForegroundColor Gray
    if (Test-Path $TargetModulePath) {
        try {
            & $TargetModulePath
        } catch {
            Write-Host "[ERROR] $_" -ForegroundColor Red
            Write-WinOptLog "Module error: $_" 'ERROR'
            Wait-WinOptEnter
        }
    } else {
        Write-Host "$(T 'module_missing') $TargetModulePath" -ForegroundColor Red
        Wait-WinOptEnter
    }
} while ($true)
