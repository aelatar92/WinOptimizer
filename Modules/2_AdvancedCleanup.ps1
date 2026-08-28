$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'AdvancedCleanup'

function Clear-WinOptRecycleBin {
    Invoke-WinOptWithProgress 'Recycle Bin' {
        cmd /c "rd /s /q %systemdrive%\`$Recycle.bin" 2>$null | Out-Null
    }
}

function Invoke-DuplicateFileFinder {
    Clear-Host
    Write-Host '=== Duplicate File Finder ===' -ForegroundColor Yellow
    $target = Read-Host "Path to scan (default: $env:USERPROFILE\Downloads)"
    if (-not $target) { $target = "$env:USERPROFILE\Downloads" }
    if (-not (Test-Path $target)) {
        Write-Host 'Path not found.' -ForegroundColor Red
        return
    }

    Write-Host "`nScanning $target for duplicates - this may take a while for large folders..." -ForegroundColor Cyan
    Write-WinOptLog "Duplicate scan started: $target"

    $files = @(Get-ChildItem -Path $target -File -Recurse -Force -ErrorAction SilentlyContinue)
    Write-Host "Found $($files.Count) files. Grouping by size..." -ForegroundColor Gray

    $bySize = $files | Group-Object Length | Where-Object { $_.Count -gt 1 -and $_.Name -ne '0' }
    Write-Host "$($bySize.Count) size group(s) with potential duplicates. Hashing..." -ForegroundColor Gray

    $dupGroups = @()
    foreach ($sizeGroup in $bySize) {
        $hashGroups = $sizeGroup.Group | Group-Object { (Get-FileHash -Path $_.FullName -Algorithm SHA256 -ErrorAction SilentlyContinue).Hash }
        foreach ($hg in $hashGroups) {
            if ($hg.Count -gt 1 -and $hg.Name) {
                $dupGroups += [pscustomobject]@{
                    Files       = @($hg.Group)
                    SizeEach    = $hg.Group[0].Length
                    WastedBytes = [int64]($hg.Group[0].Length * ($hg.Count - 1))
                }
            }
        }
    }

    if ($dupGroups.Count -eq 0) {
        Write-Host "`nNo duplicate files found." -ForegroundColor Green
        return
    }

    $totalWasted = ($dupGroups | Measure-Object -Property WastedBytes -Sum).Sum
    Clear-Host
    Write-Host "=== Duplicate File Finder: $target ===" -ForegroundColor Yellow
    Write-Host "Found $($dupGroups.Count) duplicate group(s), wasting $([Math]::Round($totalWasted / 1MB, 1)) MB`n" -ForegroundColor Cyan

    $i = 0
    foreach ($g in ($dupGroups | Sort-Object WastedBytes -Descending)) {
        $i++
        Write-Host "[$i] $($g.Files.Count) copies, $([Math]::Round($g.SizeEach / 1KB, 1)) KB each:" -ForegroundColor White
        foreach ($f in $g.Files) { Write-Host "     $($f.FullName)" -ForegroundColor Gray }
    }

    if (Confirm-WinOptRisky 'Delete duplicate copies? (keeps the first file listed in each group, deletes the rest)') {
        $deleted = 0
        $freedBytes = 0L
        foreach ($g in $dupGroups) {
            $rest = $g.Files[1..($g.Files.Count - 1)]
            foreach ($f in $rest) {
                try {
                    Remove-Item -Path $f.FullName -Force -ErrorAction Stop
                    $deleted++
                    $freedBytes += $f.Length
                } catch {
                    Write-Host "  [SKIP] $($f.FullName): $_" -ForegroundColor Yellow
                }
            }
        }
        Write-Host "`nDeleted $deleted duplicate file(s), freed $([Math]::Round($freedBytes / 1MB, 1)) MB." -ForegroundColor Green
        Write-WinOptLog "Duplicate cleanup: deleted $deleted files, freed $freedBytes bytes from $target"
    }
}

function Show-AdvancedCleanup-Menu {
    Clear-Host
    Write-Host '=== Advanced Cleanup ===' -ForegroundColor Yellow
    Write-Host '1. Empty Recycle Bin' -ForegroundColor White
    Write-Host '2. Delivery Optimization cache' -ForegroundColor White
    Write-Host '3. WinSxS (Component Cleanup)' -ForegroundColor White
    Write-Host '4. All safe (1-3)' -ForegroundColor White
    Write-Host '5. Duplicate File Finder' -ForegroundColor White
    Write-Host '6. Back' -ForegroundColor Red
}

do {
    Show-AdvancedCleanup-Menu
    $ch = Read-Host '>'

    if ($ch -in @('3', '4')) {
        if (-not (Confirm-WinOptRisky 'WinSxS cleanup uses DISM and may take a long time.')) { $ch = '' ; continue }
        Ensure-WinOptRestorePoint -Description 'WinOptimizer_AdvCleanup'
    }

    switch ($ch) {
        '1' { Clear-WinOptRecycleBin; Write-Host 'Done.' -ForegroundColor Green; Wait-WinOptEnter }
        '2' {
            Invoke-WinOptWithProgress 'Delivery Optimization cache' {
                $p = "$env:SystemRoot\SoftwareDistribution\DeliveryOptimization\Cache"
                if (Test-Path $p) { Remove-Item "$p\*" -Recurse -Force -ErrorAction SilentlyContinue }
            }
            Write-Host 'Done.' -ForegroundColor Green
            Wait-WinOptEnter
        }
        '3' {
            Invoke-WinOptWithProgress 'DISM StartComponentCleanup' {
                & DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase
            }
            Write-Host 'Done.' -ForegroundColor Green
            Wait-WinOptEnter
        }
        '4' {
            Clear-WinOptRecycleBin
            Invoke-WinOptWithProgress 'Delivery Optimization cache' {
                $p = "$env:SystemRoot\SoftwareDistribution\DeliveryOptimization\Cache"
                if (Test-Path $p) { Remove-Item "$p\*" -Recurse -Force -ErrorAction SilentlyContinue }
            }
            Invoke-WinOptWithProgress 'DISM StartComponentCleanup' {
                & DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase
            }
            Write-Host 'Done.' -ForegroundColor Green
            Wait-WinOptEnter
        }
        '5' { Invoke-DuplicateFileFinder; Wait-WinOptEnter }
        '6' { break }
    }
} while ($ch -ne '6')
