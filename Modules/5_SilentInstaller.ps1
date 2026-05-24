$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'SilentInstaller'

function Show-Installer-Menu {
    Clear-Host
    Write-Host '=== Winget Installer ===' -ForegroundColor Yellow
    Write-Host '1. Update all   2. Essential bundle   3. Developer   4. Gaming   5. Office' -ForegroundColor White
    Write-Host '6. Custom search   7. Uninstall/Purge   8. Export packages   9. Import packages   0. Back' -ForegroundColor White
}

function Install-WingetBundle {
    param([string[]]$AppIds, [string]$Label)
    Write-Host "`n[+] Bundle: $Label" -ForegroundColor Cyan
    foreach ($App in $AppIds) {
        Write-Host "  -> $App" -ForegroundColor Gray
        try {
            Invoke-WingetCommand -WingetArgs @('install', '--id', $App, '--silent', '--accept-source-agreements', '--accept-package-agreements') -SuccessCodes @(0, -1978335189) | Out-Null
            Write-Host "  [OK] $App" -ForegroundColor Green
        } catch {
            Write-Host "  [SKIP] $App : $_" -ForegroundColor Yellow
            Write-WinOptLog "Install skip $App : $_" 'WARN'
        }
    }
}

function Get-BundleApps {
    param([string]$Name)
    $b = $script:WinOptConfig.wingetBundles
    if ($b -is [pscustomobject]) {
        $arr = $b.$Name
        if ($arr) { return @($arr) }
    }
    $defaults = @{
        essential = @('BraveSoftware.BraveBrowser', 'Tonec.InternetDownloadManager', 'VideoLAN.VLC', '7zip.7zip')
        developer = @('Git.Git', 'Microsoft.VisualStudioCode', 'OpenJS.NodeJS.LTS', '7zip.7zip')
        gaming    = @('Valve.Steam', 'Discord.Discord', 'VideoLAN.VLC', '7zip.7zip')
        office    = @('LibreOffice.LibreOffice', '7zip.7zip', 'Microsoft.PowerToys')
    }
    return $defaults[$Name]
}

do {
    Show-Installer-Menu
    $insChoice = Read-Host '>'
    switch ($insChoice) {
        '1' {
            try {
                Invoke-WingetCommand -WingetArgs @('upgrade', '--all', '--silent', '--accept-source-agreements', '--accept-package-agreements') -SuccessCodes @(0, -1978335212)
                Write-Host '[SUCCESS] Upgrade finished.' -ForegroundColor Green
            } catch { Write-Host "[ERROR] $_" -ForegroundColor Red }
            Wait-WinOptEnter
        }
        '2' { Install-WingetBundle -AppIds (Get-BundleApps 'essential') -Label 'Essential'; Start-Sleep 2 }
        '3' { Install-WingetBundle -AppIds (Get-BundleApps 'developer') -Label 'Developer'; Start-Sleep 2 }
        '4' { Install-WingetBundle -AppIds (Get-BundleApps 'gaming') -Label 'Gaming'; Start-Sleep 2 }
        '5' { Install-WingetBundle -AppIds (Get-BundleApps 'office') -Label 'Office'; Start-Sleep 2 }
        '6' {
            $q = Read-Host 'Search query'
            if ($q) {
                try {
                    Invoke-WingetCommand -WingetArgs @('search', $q)
                    $id = Read-Host 'App ID to install'
                    if ($id) {
                        Invoke-WingetCommand -WingetArgs @('install', '--id', $id, '--silent', '--accept-source-agreements', '--accept-package-agreements') -SuccessCodes @(0, -1978335189)
                    }
                } catch { Write-Host "[ERROR] $_" -ForegroundColor Red }
            }
            Wait-WinOptEnter
        }
        '7' {
            try {
                Invoke-WingetCommand -WingetArgs @('list')
                $id = Read-Host 'App ID to uninstall'
                if ($id) {
                    Invoke-WingetCommand -WingetArgs @('uninstall', '--id', $id, '--silent') -SuccessCodes @(0, -1978335212)
                    $paths = winget show --id $id 2>$null | Select-String 'Install Location'
                    Write-Host 'Check Install Location above for leftover folders.' -ForegroundColor Yellow
                }
            } catch { Write-Host "[ERROR] $_" -ForegroundColor Red }
            Wait-WinOptEnter
        }
        '8' {
            $out = Join-Path $WinOptRoot "Data\exports\winget_export_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
            New-Item -Path (Split-Path $out) -ItemType Directory -Force | Out-Null
            & winget export -o $out --include-versions
            Write-Host "Exported: $out" -ForegroundColor Green
            Wait-WinOptEnter
        }
        '9' {
            $in = Read-Host 'Full path to export JSON'
            if (Test-Path $in) {
                & winget import -i $in
                Write-Host "Import exit: $LASTEXITCODE" -ForegroundColor Cyan
            }
            Wait-WinOptEnter
        }
        '0' { break }
    }
} while ($insChoice -ne '0')
