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
    Write-Host "  $(T 'menu_title') v$script:WinOptVersion" -ForegroundColor Yellow
    Write-Host "  $(T 'menu_mode') $script:WinOptMode" -ForegroundColor Gray
    Write-Host "========================================================================================" -ForegroundColor Cyan
    Write-Host "  $(T 'menu_1')" -ForegroundColor White
    Write-Host "  $(T 'menu_2')" -ForegroundColor White
    Write-Host "  $(T 'menu_3')" -ForegroundColor White
    Write-Host "  $(T 'menu_4')" -ForegroundColor White
    Write-Host "  $(T 'menu_5')" -ForegroundColor White
    Write-Host "  $(T 'menu_6')" -ForegroundColor White
    Write-Host "  $(T 'menu_7')" -ForegroundColor White
    Write-Host "  $(T 'menu_8')" -ForegroundColor White
    Write-Host "  $(T 'menu_9')" -ForegroundColor White
    Write-Host "  $(T 'menu_10')" -ForegroundColor White
    Write-Host "  $(T 'menu_11')" -ForegroundColor White
    Write-Host "  $(T 'menu_12')" -ForegroundColor White
    Write-Host "  $(T 'menu_13')" -ForegroundColor White
    Write-Host "  $(T 'menu_14')" -ForegroundColor White
    Write-Host "  $(T 'menu_15')" -ForegroundColor White
    Write-Host "  $(T 'menu_16')" -ForegroundColor White
    Write-Host "  $(T 'menu_17')" -ForegroundColor White
    Write-Host "  $(T 'menu_18')" -ForegroundColor Red
    Write-Host "----------------------------------------------------------------------------------------" -ForegroundColor DarkGray
}

function Show-Help-Guide {
    Clear-Host
    Write-Host (T 'help_line1') -ForegroundColor Cyan
    Write-Host (T 'help_line2') -ForegroundColor Gray
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
    '16' = @{ Path = 'Modules\16_SmartProfiles.ps1'; Num = 16 }
}

$menuItems = @(1..18)
if ($script:WinOptMode -eq 'beginner') {
    $menuItems = @($script:WinOptConfig.beginnerAllowedModules)
}

do {
    Show-Main-Menu
    if ($script:WinOptMode -eq 'beginner') {
        Write-Host "  $((T 'menu_beginner_note') -f ($menuItems -join ', '))" -ForegroundColor DarkGray
    }
    $MainChoice = Read-Host (T 'menu_select')

    if ($MainChoice -eq '17') { Show-Help-Guide; continue }
    if ($MainChoice -eq '18') {
        Write-Host "`n$((T 'menu_exit_bye') -f $script:WinOptVersion)" -ForegroundColor Green
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
