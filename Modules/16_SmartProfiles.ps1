$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'SmartProfiles'

if (-not $script:WinOptConfig.enableSmartProfiles) {
    Write-Host (T 'profiles_disabled') -ForegroundColor Yellow
    Wait-WinOptEnter
    return
}

function Show-Profiles-Menu {
    Clear-Host
    Write-Host (T 'profiles_title') -ForegroundColor Yellow
    Write-Host (T 'profiles_gaming') -ForegroundColor White
    Write-Host (T 'profiles_battery') -ForegroundColor White
    Write-Host (T 'profiles_privacy') -ForegroundColor White
    Write-Host (T 'profiles_developer') -ForegroundColor White
    Write-Host (T 'profiles_back') -ForegroundColor Red
}

function Invoke-GamingProfile {
    Write-Host "`n$(T 'profiles_applying') Gaming" -ForegroundColor Cyan
    if (-not (Confirm-WinOptRisky 'Apply Ultimate Performance power plan + gaming registry tweaks?')) { return }
    Ensure-WinOptRestorePoint -Description 'WinOptimizer_Profile_Gaming'

    Invoke-WinOptWithProgress 'Ultimate Performance power plan' {
        & powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
        & powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    }

    Invoke-WinOptWithProgress 'Gaming registry tweaks' {
        $NetMultimediaPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
        Backup-WinOptRegistryValue -Path $NetMultimediaPath -Name 'NetworkThrottlingIndex' -Label 'gaming_net'
        Backup-WinOptRegistryValue -Path $NetMultimediaPath -Name 'SystemResponsiveness' -Label 'gaming_resp'
        if (-not (Test-Path $NetMultimediaPath)) { New-Item -Path $NetMultimediaPath -Force | Out-Null }
        Set-ItemProperty -Path $NetMultimediaPath -Name 'NetworkThrottlingIndex' -Value 0xFFFFFFFF -Force
        Set-ItemProperty -Path $NetMultimediaPath -Name 'SystemResponsiveness' -Value 0 -Force

        $GameModePath = 'HKCU:\Software\Microsoft\GameBar'
        if (-not (Test-Path $GameModePath)) { New-Item -Path $GameModePath -Force | Out-Null }
        Set-ItemProperty -Path $GameModePath -Name 'AllowAutoGameMode' -Value 1 -Force
    }

    Invoke-WinOptWithProgress 'Clear gaming platform cache' {
        foreach ($p in ("$env:LocalAppData\Steam\htmlcache\*", "$env:LocalAppData\EpicGamesLauncher\Saved\webcache\*", "$env:AppData\discord\Cache\*")) {
            Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Write-Host (T 'profiles_done') -ForegroundColor Green
}

function Invoke-BatteryProfile {
    Write-Host "`n$(T 'profiles_applying') Battery Saver" -ForegroundColor Cyan
    Invoke-WinOptWithProgress 'Power Saver plan' {
        & powercfg -setactive a1841308-3541-4fab-bc81-f71556f20b4a | Out-Null
    }
    Invoke-WinOptWithProgress 'Reduce screen/sleep timeouts on battery' {
        & powercfg -change -monitor-timeout-dc 3 | Out-Null
        & powercfg -change -standby-timeout-dc 10 | Out-Null
    }
    Write-Host (T 'profiles_done') -ForegroundColor Green
}

function Invoke-PrivacyProfile {
    Write-Host "`n$(T 'profiles_applying') Privacy / Clean" -ForegroundColor Cyan
    if (-not (Confirm-WinOptRisky 'Disable telemetry/update services and run Advanced Cleanup?')) { return }
    Ensure-WinOptRestorePoint -Description 'WinOptimizer_Profile_Privacy'

    Invoke-WinOptWithProgress 'Disable telemetry service (DiagTrack)' {
        Stop-Service -Name DiagTrack -Force -ErrorAction SilentlyContinue
        Set-Service -Name DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
    }
    Invoke-WinOptWithProgress 'Empty Recycle Bin' {
        cmd /c "rd /s /q %systemdrive%\`$Recycle.bin" 2>$null | Out-Null
    }
    Invoke-WinOptWithProgress 'Clear Delivery Optimization cache' {
        $p = "$env:SystemRoot\SoftwareDistribution\DeliveryOptimization\Cache"
        if (Test-Path $p) { Remove-Item "$p\*" -Recurse -Force -ErrorAction SilentlyContinue }
    }

    Write-Host (T 'profiles_done') -ForegroundColor Green
}

function Invoke-DeveloperProfile {
    Write-Host "`n$(T 'profiles_applying') Developer" -ForegroundColor Cyan
    $apps = @()
    $bundles = $script:WinOptConfig.wingetBundles
    if ($bundles -and $bundles.developer) { $apps = @($bundles.developer) }
    if (-not $apps -or $apps.Count -eq 0) { $apps = @('Git.Git', 'Microsoft.VisualStudioCode', 'OpenJS.NodeJS.LTS', '7zip.7zip') }

    foreach ($App in $apps) {
        Write-Host "  -> $App" -ForegroundColor Gray
        try {
            Invoke-WingetCommand -WingetArgs @('install', '--id', $App, '--silent', '--accept-source-agreements', '--accept-package-agreements') -SuccessCodes @(0, -1978335189) | Out-Null
            Write-Host "  [OK] $App" -ForegroundColor Green
        } catch {
            Write-Host "  [SKIP] $App : $_" -ForegroundColor Yellow
            Write-WinOptLog "Profile install skip $App : $_" 'WARN'
        }
    }
    Write-Host (T 'profiles_done') -ForegroundColor Green
}

do {
    Show-Profiles-Menu
    $pChoice = Read-Host '>'
    switch ($pChoice) {
        '1' { Invoke-GamingProfile; Wait-WinOptEnter }
        '2' { Invoke-BatteryProfile; Wait-WinOptEnter }
        '3' { Invoke-PrivacyProfile; Wait-WinOptEnter }
        '4' { Invoke-DeveloperProfile; Wait-WinOptEnter }
        '5' { break }
        default { Write-Host (T 'invalid_choice') -ForegroundColor Yellow; Start-Sleep -Seconds 1 }
    }
} while ($pChoice -ne '5')
