$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'Settings'

function Show-Settings-Menu {
    Clear-Host
    Write-Host (T 'settings_title') -ForegroundColor Yellow
    Write-Host (T 'settings_1') -ForegroundColor White
    Write-Host (T 'settings_2') -ForegroundColor White
    Write-Host (T 'settings_3') -ForegroundColor White
    Write-Host (T 'settings_4') -ForegroundColor White
    Write-Host (T 'settings_5') -ForegroundColor White
    Write-Host (T 'settings_6') -ForegroundColor White
    Write-Host (T 'settings_7') -ForegroundColor White
    Write-Host (T 'settings_8') -ForegroundColor White
    Write-Host (T 'settings_9') -ForegroundColor Red
}

function Show-ClaudeAI-Settings {
    do {
        Clear-Host
        Write-Host (T 'claude_menu_title') -ForegroundColor Yellow
        $statusText = if ($script:WinOptConfig.enableClaudeAI) { T 'claude_menu_enabled' } else { T 'claude_menu_disabled' }
        $keyText = if (Get-WinOptClaudeApiKey) { T 'claude_menu_keyset' } else { T 'claude_menu_keymissing' }
        Write-Host "$(T 'claude_menu_status') $statusText | $keyText | Model: $($script:WinOptConfig.claudeModel)" -ForegroundColor Gray
        Write-Host (T 'claude_menu_1') -ForegroundColor White
        Write-Host (T 'claude_menu_2') -ForegroundColor White
        Write-Host (T 'claude_menu_3') -ForegroundColor White
        Write-Host (T 'claude_menu_4') -ForegroundColor White
        Write-Host (T 'claude_menu_5') -ForegroundColor Red
        $cc = Read-Host '>'
        switch ($cc) {
            '1' {
                $secure = Read-Host (T 'claude_prompt_key') -AsSecureString
                if ($secure.Length -eq 0) {
                    Write-Host (T 'claude_key_empty') -ForegroundColor Yellow
                } else {
                    Set-WinOptClaudeApiKey -SecureKey $secure
                    Write-Host (T 'claude_key_saved') -ForegroundColor Green
                }
            }
            '2' {
                Clear-WinOptClaudeApiKey
                Write-Host (T 'claude_key_cleared') -ForegroundColor Green
            }
            '3' {
                $script:WinOptConfig.enableClaudeAI = -not [bool]$script:WinOptConfig.enableClaudeAI
                Save-WinOptConfig
                $statusText = if ($script:WinOptConfig.enableClaudeAI) { T 'claude_menu_enabled' } else { T 'claude_menu_disabled' }
                Write-Host "$(T 'claude_toggled') $statusText" -ForegroundColor Cyan
            }
            '4' {
                Write-Host (T 'claude_model_prompt')
                $mc = Read-Host
                $script:WinOptConfig.claudeModel = switch ($mc) {
                    '2' { 'claude-haiku-4-5-20251001' }
                    '3' { 'claude-opus-5' }
                    default { 'claude-sonnet-5' }
                }
                Save-WinOptConfig
                Write-Host "$(T 'claude_model_set') $($script:WinOptConfig.claudeModel)" -ForegroundColor Green
            }
            '5' { return }
        }
        if ($cc -ne '5') { Wait-WinOptEnter }
    } while ($cc -ne '5')
}

do {
    Show-Settings-Menu
    $c = Read-Host '>'
    switch ($c) {
        '1' {
            Write-Host '1 = Beginner   2 = Advanced'
            $m = Read-Host
            $script:WinOptMode = if ($m -eq '1') { 'beginner' } else { 'advanced' }
            $script:WinOptConfig.uiMode = $script:WinOptMode
            Save-WinOptConfig
            Write-Host "Mode: $script:WinOptMode" -ForegroundColor Green
        }
        '2' {
            $script:WinOptConfig.confirmRiskyActions = -not [bool]$script:WinOptConfig.confirmRiskyActions
            Save-WinOptConfig
            Write-Host "confirmRiskyActions = $($script:WinOptConfig.confirmRiskyActions)" -ForegroundColor Cyan
        }
        '3' { Restore-WinOptDnsSnapshot }
        '4' { Restore-WinOptRegistryBackup }
        '5' {
            $logDir = Join-Path $WinOptRoot 'logs'
            Start-Process explorer.exe $logDir
        }
        '6' {
            Write-Host "Installed: v$script:WinOptVersion" -ForegroundColor Cyan
            $url = $script:WinOptConfig.updateCheckUrl
            if ($url) {
                try {
                    $remote = Invoke-RestMethod -Uri $url -TimeoutSec 5
                    $remoteVer = $remote.version
                    if ($remoteVer -and $remoteVer -ne $script:WinOptVersion) {
                        Write-Host "Update available: $remoteVer (you have $script:WinOptVersion)" -ForegroundColor Yellow
                    } else {
                        Write-Host 'You are up to date (or could not compare).' -ForegroundColor Green
                    }
                } catch { Write-Host "Could not reach update URL: $_" -ForegroundColor Yellow }
            } else { Write-Host 'No updateCheckUrl in config.' -ForegroundColor Gray }
        }
        '7' {
            Write-Host '1 = English   2 = Arabic (عربي)'
            $l = Read-Host
            $script:WinOptConfig.language = if ($l -eq '2') { 'ar' } else { 'en' }
            Save-WinOptConfig
            Write-Host "Language / اللغة: $($script:WinOptConfig.language)" -ForegroundColor Green
        }
        '8' { Show-ClaudeAI-Settings }
        '9' { break }
    }
    if ($c -ne '9' -and $c -ne '8') { Wait-WinOptEnter }
} while ($c -ne '9')
