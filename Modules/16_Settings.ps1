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
    Write-Host (T 'settings_9') -ForegroundColor White
    Write-Host (T 'settings_10') -ForegroundColor White
    Write-Host (T 'settings_11') -ForegroundColor White
    Write-Host (T 'settings_12') -ForegroundColor Red
}

function Show-LocalAI-Settings {
    do {
        Clear-Host
        Write-Host (T 'localai_menu_title') -ForegroundColor Yellow
        $statusText = if ($script:WinOptConfig.enableLocalAI) { T 'localai_menu_enabled' } else { T 'localai_menu_disabled' }
        $reachText = if (Test-WinOptOllamaReachable) { T 'localai_menu_ready' } else { T 'localai_menu_notready' }
        Write-Host "$(T 'localai_menu_status') $statusText | $reachText | Model: $($script:WinOptConfig.localAIModel)" -ForegroundColor Gray
        Write-Host (T 'localai_menu_1') -ForegroundColor White
        Write-Host (T 'localai_menu_2') -ForegroundColor White
        Write-Host (T 'localai_menu_3') -ForegroundColor White
        Write-Host (T 'localai_menu_4') -ForegroundColor Red
        $lc = Read-Host '>'
        switch ($lc) {
            '1' {
                $script:WinOptConfig.enableLocalAI = -not [bool]$script:WinOptConfig.enableLocalAI
                Save-WinOptConfig
                $statusText = if ($script:WinOptConfig.enableLocalAI) { T 'localai_menu_enabled' } else { T 'localai_menu_disabled' }
                Write-Host "$(T 'localai_toggled') $statusText" -ForegroundColor Cyan
            }
            '2' {
                Write-Host (T 'localai_model_prompt')
                $m = Read-Host
                if ($m) {
                    $script:WinOptConfig.localAIModel = $m
                    Save-WinOptConfig
                    Write-Host "$(T 'localai_model_set') $($script:WinOptConfig.localAIModel)" -ForegroundColor Green
                }
            }
            '3' {
                if (Test-WinOptOllamaReachable) {
                    Write-Host (T 'localai_test_ok') -ForegroundColor Green
                } else {
                    Write-Host "$(T 'localai_test_fail') $($script:WinOptConfig.localAIModel)" -ForegroundColor Yellow
                    if ($script:WinOptLastOllamaError) { Write-Host "Details: $script:WinOptLastOllamaError" -ForegroundColor DarkGray }
                }
            }
            '4' { return }
        }
        if ($lc -ne '4') { Wait-WinOptEnter }
    } while ($lc -ne '4')
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
                    $remoteVer = if ($remote.tag_name) { $remote.tag_name.TrimStart('v') } else { $remote.version }
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
        '8' { Show-LocalAI-Settings }
        '9' {
            $exportDir = Join-Path $WinOptRoot 'Data\exports'
            if (-not (Test-Path $exportDir)) { New-Item $exportDir -ItemType Directory -Force | Out-Null }
            $default = Join-Path $exportDir "winopt_profile_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
            $out = Read-Host "Export path (default: $default)"
            if (-not $out) { $out = $default }
            try {
                $script:WinOptConfig | ConvertTo-Json -Depth 8 | Set-Content -Path $out -Encoding UTF8
                Write-Host "Settings profile exported: $out" -ForegroundColor Green
                Write-WinOptLog "Settings profile exported to $out"
            } catch {
                Write-Host "Export failed: $_" -ForegroundColor Red
            }
        }
        '10' {
            $in = Read-Host 'Full path to a settings profile JSON to import'
            if (-not $in -or -not (Test-Path $in)) { Write-Host 'File not found.' -ForegroundColor Red; break }
            try {
                $imported = Get-Content $in -Raw -Encoding UTF8 | ConvertFrom-Json
            } catch {
                Write-Host "Not a valid settings profile: $_" -ForegroundColor Red
                break
            }
            if (-not (Confirm-WinOptRisky "Import settings from $in? This overwrites your current WinOptimizer settings.")) { break }
            foreach ($prop in $imported.PSObject.Properties) {
                if ($prop.Name -eq 'version') { continue }
                $script:WinOptConfig[$prop.Name] = $prop.Value
            }
            $script:WinOptMode = if ($script:WinOptConfig.uiMode -in @('beginner', 'advanced')) { $script:WinOptConfig.uiMode } else { 'advanced' }
            Save-WinOptConfig
            Write-Host "Settings profile imported from $in" -ForegroundColor Green
            Write-WinOptLog "Settings profile imported from $in"
        }
        '11' {
            $logDir = Join-Path $WinOptRoot 'logs'
            $logFiles = @(Get-ChildItem -Path $logDir -Filter '*.log' -ErrorAction SilentlyContinue | Sort-Object Name)
            if ($logFiles.Count -eq 0) {
                Write-Host 'No logs found yet.' -ForegroundColor Yellow
                break
            }
            $allLines = @()
            foreach ($f in $logFiles) { $allLines += @(Get-Content -Path $f.FullName -ErrorAction SilentlyContinue) }

            # Pure session/navigation bookkeeping carries no action content, so it's
            # excluded here to keep the report to actual activity. Every other
            # Write-WinOptLog call in the codebase represents an attempted or
            # completed action, a warning, or an error, and is kept.
            $noisePatterns = @(
                'Session started', 'Module entered:', '\] OS: ', 'Application exit',
                'Tray monitor started', 'Listed \d+ startup items', '\] Ping ',
                'Disk space analysis (started|complete)', 'Duplicate scan started'
            )
            $filtered = foreach ($line in $allLines) {
                $isNoise = $false
                foreach ($pattern in $noisePatterns) {
                    if ($line -match $pattern) { $isNoise = $true; break }
                }
                if (-not $isNoise) { $line }
            }
            $filtered = @($filtered)

            if ($filtered.Count -eq 0) {
                Write-Host 'No activity to report (only session bookkeeping found in the logs).' -ForegroundColor Gray
            } else {
                $path = Export-WinOptAuditReport -Lines $filtered
                Write-Host "Audit report generated: $path ($($filtered.Count) entries)" -ForegroundColor Green
                Start-Process $path
            }
        }
        '12' { break }
    }
    if ($c -ne '12' -and $c -ne '8') { Wait-WinOptEnter }
} while ($c -ne '12')
