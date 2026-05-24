$projectRoot = Split-Path $PSScriptRoot -Parent

Describe 'WinOptimizer file structure' {
    It 'has config.json' {
        Test-Path (Join-Path $projectRoot 'config.json') | Should Be $true
    }
    It 'has Common library' {
        Test-Path (Join-Path $projectRoot 'Lib\Common.ps1') | Should Be $true
    }
}

Describe 'WinOptimizer PowerShell syntax' {
    $files = @(
        'Main.ps1', 'Lib\Common.ps1',
        'Modules\1_OptimizeOS.ps1', 'Modules\2_DiskTools.ps1', 'Modules\3_AdvancedTools.ps1',
        'Modules\4_DriversRepair.ps1', 'Modules\5_SilentInstaller.ps1', 'Modules\6_SecurityBackup.ps1',
        'Modules\7_AIDiagnostics.ps1', 'Modules\8_StartupManager.ps1', 'Modules\9_WindowsServices.ps1',
        'Modules\10_AdvancedCleanup.ps1', 'Modules\11_NetworkTools.ps1', 'Modules\12_BackupExport.ps1',
        'Modules\13_BatteryHealth.ps1', 'Modules\14_Scheduler.ps1', 'Modules\15_Settings.ps1'
    )
    foreach ($rel in $files) {
        $full = Join-Path $projectRoot $rel
        It "parses $rel" {
            $errs = $null
            [void][System.Management.Automation.Language.Parser]::ParseFile($full, [ref]$null, [ref]$errs)
            ($errs | Measure-Object).Count | Should Be 0
        }
    }
}

Describe 'WinOptimizer Common library' {
    BeforeAll {
        . (Join-Path $projectRoot 'Lib\Common.ps1')
        Initialize-WinOpt -Root $projectRoot
    }
    It 'loads config' {
        $script:WinOptConfig | Should Not BeNullOrEmpty
    }
    It 'returns health score 0-100' {
        $h = Get-WinOptHealthScore
        $h.Score | Should BeGreaterThan 0
        $h.Score | Should BeLessThan 101
    }
}
