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
    Write-Host (T 'settings_8') -ForegroundColor Red
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
        '8' { break }
    }
    if ($c -ne '8') { Wait-WinOptEnter }
} while ($c -ne '8')
