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
        'Modules\16_SmartProfiles.ps1',
        'Gui\GuiCommon.ps1', 'Gui\MainWindow.ps1', 'Gui\SettingsWindow.ps1'
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

    It 'has a UTF-8 BOM if it contains non-ASCII text (else Windows PowerShell 5.1 misreads it)' -ForEach $files {
        $full = Join-Path $script:projectRoot $_
        $bytes = [System.IO.File]::ReadAllBytes($full)
        $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
        $hasNonAscii = @($bytes | Where-Object { $_ -ge 0x80 }).Count -gt 0
        if ($hasNonAscii) { $hasBom | Should -Be $true }
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

    It 'every i18n key exists in both the en and ar tables' {
        $enKeys = $script:WinOptStrings['en'].Keys
        $arKeys = $script:WinOptStrings['ar'].Keys
        $missingFromAr = @($enKeys | Where-Object { $_ -notin $arKeys })
        $missingFromEn = @($arKeys | Where-Object { $_ -notin $enKeys })
        $missingFromAr | Should -BeNullOrEmpty -Because "these keys exist in 'en' but not 'ar': $($missingFromAr -join ', ')"
        $missingFromEn | Should -BeNullOrEmpty -Because "these keys exist in 'ar' but not 'en': $($missingFromEn -join ', ')"
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

    It 'Save-WinOptConfig round-trips the local AI model name' {
        $script:WinOptConfig.localAIModel = 'llama3.2'
        Save-WinOptConfig

        Import-WinOptConfig

        $script:WinOptConfig.localAIModel | Should -Be 'llama3.2'

        $script:WinOptConfig.localAIModel = 'qwen2.5:3b'
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

Describe 'WinOptimizer GUI XAML validity' {
    $guiFiles = @('Gui\MainWindow.ps1', 'Gui\SettingsWindow.ps1')
    BeforeAll {
        $script:projectRoot = Split-Path $PSScriptRoot -Parent
    }
    It 'embedded XAML in <_> is well-formed XML' -ForEach $guiFiles {
        $full = Join-Path $script:projectRoot $_
        $tokens = $null
        $errs = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($full, [ref]$tokens, [ref]$errs)
        $hereStrings = @($tokens | Where-Object { $_.Kind -eq 'HereStringExpandable' -or $_.Kind -eq 'HereStringLiteral' })
        $hereStrings.Count | Should -BeGreaterThan 0
        foreach ($hs in $hereStrings) {
            { [xml]$hs.Value } | Should -Not -Throw
        }
    }
}

Describe 'WinOptimizer Local AI integration' {
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

    It 'Test-WinOptOllamaReachable is true when Ollama responds' {
        Mock -CommandName Invoke-RestMethod -MockWith { [pscustomobject]@{ models = @() } }
        Test-WinOptOllamaReachable | Should -Be $true
    }

    It 'Test-WinOptOllamaReachable is false when Ollama is unreachable' {
        Mock -CommandName Invoke-RestMethod -MockWith { throw 'connection refused' }
        Test-WinOptOllamaReachable | Should -Be $false
    }

    It 'Test-WinOptLocalAIReady is false when disabled even if Ollama is reachable' {
        Mock -CommandName Invoke-RestMethod -MockWith { [pscustomobject]@{ models = @() } }
        $script:WinOptConfig.enableLocalAI = $false
        Test-WinOptLocalAIReady | Should -Be $false
    }

    It 'Test-WinOptLocalAIReady is true when enabled and Ollama is reachable' {
        Mock -CommandName Invoke-RestMethod -MockWith { [pscustomobject]@{ models = @() } }
        $script:WinOptConfig.enableLocalAI = $true
        Test-WinOptLocalAIReady | Should -Be $true
        $script:WinOptConfig.enableLocalAI = $false
    }

    It 'Invoke-WinOptLocalAI calls the Ollama chat API with the configured model and parses the response' {
        $script:WinOptConfig.localAIModel = 'qwen2.5:3b'
        Mock -CommandName Invoke-RestMethod -MockWith {
            [pscustomobject]@{ message = [pscustomobject]@{ role = 'assistant'; content = 'Mocked local analysis.' } }
        }
        $result = Invoke-WinOptLocalAI -SystemPrompt 'You are a helper' -UserPrompt '{"disk":"ok"}'
        $result | Should -Be 'Mocked local analysis.'
        Should -Invoke -CommandName Invoke-RestMethod -Times 1 -ParameterFilter {
            $Uri -eq 'http://localhost:11434/api/chat' -and
            $Body -match 'qwen2.5:3b'
        }
    }

    It 'Invoke-WinOptLocalAI throws a clear error when Ollama is unreachable' {
        Mock -CommandName Invoke-RestMethod -MockWith { throw 'connection refused' }
        { Invoke-WinOptLocalAI -SystemPrompt 'sys' -UserPrompt 'user' } | Should -Throw '*Could not reach Ollama*'
    }
}

Describe 'WinOptimizer Windows-only functionality' {
    BeforeAll {
        $script:projectRoot = Split-Path $PSScriptRoot -Parent
        . (Join-Path $script:projectRoot 'Lib\Common.ps1')
        Initialize-WinOpt -Root $script:projectRoot
    }

    It 'returns health score 0-100' -Skip:($PSVersionTable.PSEdition -eq 'Core' -and -not $IsWindows) {
        $h = Get-WinOptHealthScore
        $h.Score | Should -BeGreaterThan 0
        $h.Score | Should -BeLessThan 101
    }
}
