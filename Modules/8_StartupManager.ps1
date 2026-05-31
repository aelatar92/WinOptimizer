$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'StartupManager'

function Show-Startup-Menu {
    Clear-Host
    Write-WinOptHost '=== Startup Manager ===' -ForegroundColor Yellow
    Write-WinOptHost '1. List startup items' -ForegroundColor White
    Write-WinOptHost '2. Disable item' -ForegroundColor White
    Write-WinOptHost '3. Restore via Settings (registry backup)' -ForegroundColor White
    Write-WinOptHost '4. Back' -ForegroundColor Red
}

function Get-StartupItems {
    $items = @()
    $regPaths = @(
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'
    )
    $i = 0
    foreach ($rp in $regPaths) {
        if (-not (Test-Path $rp)) { continue }
        Get-ItemProperty $rp -ErrorAction SilentlyContinue | ForEach-Object {
            $_.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object {
                $i++
                $items += [pscustomobject]@{ Id = $i; Hive = $rp; Name = $_.Name; Command = $_.Value }
            }
        }
    }
    return $items
}

do {
    Show-Startup-Menu
    $c = Read-Host '>'
    switch ($c) {
        '1' {
            $list = Get-StartupItems
            if (-not $list) { Write-WinOptHost 'No items.' -ForegroundColor Gray; break }
            $list | Format-Table Id, Name, Command -AutoSize
            Write-WinOptLog "Listed $($list.Count) startup items"
        }
        '2' {
            $list = Get-StartupItems
            $list | Format-Table Id, Name -AutoSize
            $id = [int](Read-Host 'ID to disable')
            $item = $list | Where-Object Id -eq $id
            if ($item -and (Confirm-WinOptRisky "Disable startup: $($item.Name)")) {
                Backup-WinOptRegistryValue -Path $item.Hive -Name $item.Name -Label "startup_$($item.Name)"
                Remove-ItemProperty -Path $item.Hive -Name $item.Name -Force
                Write-WinOptHost 'Disabled.' -ForegroundColor Green
                Write-WinOptLog "Disabled startup $($item.Name)"
            }
        }
        '3' {
            Write-WinOptHost 'Use Main Menu > 15 Settings > Restore registry from backup.' -ForegroundColor Cyan
        }
        '4' { break }
    }
    if ($c -ne '4') { Wait-WinOptEnter }
} while ($c -ne '4')
