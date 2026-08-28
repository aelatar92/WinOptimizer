Describe 'WinOptimizer file structure' {
    BeforeAll {
        $script:projectRoot = Split-Path $PSScriptRoot -Parent
    }
    It 'has config.json' {
        Test-Path (Join-Path $script:projectRoot 'config.json') | Should -Be $true
    }
    It 'has Common library' {
        Test-Path (Join-Path $script:projectRoot 'Lib\Common.ps1') | Should -Be $true
    }
}

Describe 'WinOptimizer PowerShell syntax' {
    $files = @(
        'Main.ps1', 'Lib\Common.ps1',
        'Modules\1_OptimizeOS.ps1', 'Modules\2_DiskTools.ps1', 'Modules\3_AdvancedTools.ps1',
        'Modules\4_DriversRepair.ps1', 'Modules\5_SilentInstaller.ps1', 'Modules\6_SecurityBackup.ps1',
        'Modules\7_AIDiagnostics.ps1', 'Modules\8_StartupManager.ps1', 'Modules\9_WindowsServices.ps1',
        'Modules\10_AdvancedCleanup.ps1', 'Modules\11_NetworkTools.ps1', 'Modules\12_BackupExport.ps1',
        'Modules\13_BatteryHealth.ps1', 'Modules\14_Scheduler.ps1', 'Modules\15_Settings.ps1',
        'Modules\16_SmartProfiles.ps1'
    )
    BeforeAll {
        $script:projectRoot = Split-Path $PSScriptRoot -Parent
    }
    It 'parses <_>' -ForEach $files {
        $full = Join-Path $script:projectRoot $_
        $errs = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($full, [ref]$null, [ref]$errs)
        ($errs | Measure-Object).Count | Should -Be 0
    }
}

Describe 'WinOptimizer Common library - config and i18n' {
    BeforeAll {
        $script:projectRoot = Split-Path $PSScriptRoot -Parent
        $script:tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("WinOptTest_" + [guid]::NewGuid())
        New-Item -Path $script:tempRoot -ItemType Directory -Force | Out-Null
        . (Join-Path $script:projectRoot 'Lib\Common.ps1')
        Initialize-WinOpt -Root $script:tempRoot
    }
    AfterAll {
        Remove-Item -Path $script:tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }

    It 'loads config' {
        $script:WinOptConfig | Should -Not -BeNullOrEmpty
    }

    It 'defaults language to en' {
        $script:WinOptConfig.language | Should -Be 'en'
    }

    It 'T() returns an English string by default' {
        (T 'press_enter') | Should -Be 'Press Enter to continue...'
    }

    It 'T() returns an Arabic string once language is switched' {
        $script:WinOptConfig.language = 'ar'
        (T 'press_enter') | Should -Be 'اضغط Enter للمتابعة...'
        $script:WinOptConfig.language = 'en'
    }

    It 'T() falls back to the key itself for an unknown key' {
        (T 'this_key_does_not_exist') | Should -Be 'this_key_does_not_exist'
    }

    It 'Test-WinOptModuleAllowed allows everything in advanced mode' {
        $script:WinOptMode = 'advanced'
        Test-WinOptModuleAllowed -ModuleNumber 9 | Should -Be $true
    }

    It 'Test-WinOptModuleAllowed enforces the beginner allowlist' {
        $script:WinOptMode = 'beginner'
        $script:WinOptConfig.beginnerAllowedModules = @(1, 2, 6, 7, 15, 16, 17, 18)
        Test-WinOptModuleAllowed -ModuleNumber 1 | Should -Be $true
        Test-WinOptModuleAllowed -ModuleNumber 9 | Should -Be $false
        $script:WinOptMode = 'advanced'
    }

    It 'Save-WinOptConfig round-trips the Phase 1 config keys' {
        $script:WinOptConfig.language = 'ar'
        $script:WinOptConfig.enableSmartProfiles = $false
        $script:WinOptConfig.enableLocalAI = $true
        $script:WinOptConfig.autoCreateRestorePoint = $true
        Save-WinOptConfig

        Import-WinOptConfig

        $script:WinOptConfig.language | Should -Be 'ar'
        $script:WinOptConfig.enableSmartProfiles | Should -Be $false
        $script:WinOptConfig.enableLocalAI | Should -Be $true
        $script:WinOptConfig.autoCreateRestorePoint | Should -Be $true

        # reset for any later test in this run
        $script:WinOptConfig.language = 'en'
        $script:WinOptConfig.enableSmartProfiles = $true
        $script:WinOptConfig.enableLocalAI = $false
        $script:WinOptConfig.autoCreateRestorePoint = $false
        Save-WinOptConfig
    }
}

Describe 'WinOptimizer HTML report export' {
    BeforeAll {
        $script:projectRoot = Split-Path $PSScriptRoot -Parent
        $script:tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("WinOptTest_" + [guid]::NewGuid())
        New-Item -Path $script:tempRoot -ItemType Directory -Force | Out-Null
        . (Join-Path $script:projectRoot 'Lib\Common.ps1')
        Initialize-WinOpt -Root $script:tempRoot
    }
    AfterAll {
        Remove-Item -Path $script:tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }

    It 'writes an HTML file with HTML-escaped values' {
        $reportData = @{ Score = 87; Note = '<script>alert(1)</script> & co' }
        $path = Export-WinOptHtmlReport -ReportData $reportData -Title 'Test Report'
        Test-Path $path | Should -Be $true
        $content = Get-Content $path -Raw
        $content | Should -Match 'Test Report'
        $content | Should -Match '&lt;script&gt;'
        $content | Should -Not -Match '<script>alert'
    }
}

Describe 'WinOptimizer Windows-only functionality' {
    BeforeAll {
        $script:projectRoot = Split-Path $PSScriptRoot -Parent
        . (Join-Path $script:projectRoot 'Lib\Common.ps1')
        Initialize-WinOpt -Root $script:projectRoot
    }

    It 'returns health score 0-100' -Skip:(-not $IsWindows) {
        $h = Get-WinOptHealthScore
        $h.Score | Should -BeGreaterThan 0
        $h.Score | Should -BeLessThan 101
    }
}
