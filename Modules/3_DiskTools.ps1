$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'DiskTools'

function Show-DiskTools-Menu {
    Clear-Host
    Write-Host '=== Disk Tools ===' -ForegroundColor Magenta
    Write-Host '1. Full repair suite (SFC, DISM, chkdsk, Trim/Defrag)' -ForegroundColor White
    Write-Host '2. Disk Space Analyzer (largest top-level folders)' -ForegroundColor White
    Write-Host '3. Back' -ForegroundColor Red
}

function Invoke-DiskRepairSuite {
    if (-not (Confirm-WinOptRisky 'SFC and DISM can take 30-60+ minutes. Continue?')) { return }
    Ensure-WinOptRestorePoint -Description 'WinOptimizer_Before_DiskTools'

    Invoke-WinOptWithProgress 'SFC /scannow' {
        & sfc /scannow
        Write-WinOptLog "SFC exit $LASTEXITCODE"
    }

    Invoke-WinOptWithProgress 'DISM RestoreHealth' {
        & DISM /Online /Cleanup-Image /RestoreHealth
        Write-WinOptLog "DISM exit $LASTEXITCODE"
    }

    if (Confirm-WinOptRisky 'Schedule chkdsk C: /f /r on next reboot? (can take hours)') {
        Write-Output 'Y' | chkdsk C: /f /r
        Write-Host 'Chkdsk scheduled.' -ForegroundColor Green
    }

    Invoke-WinOptWithProgress 'Volume optimization' {
        $Disks = Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' }
        foreach ($Disk in $Disks) {
            $Letter = $Disk.DriveLetter
            try {
                $DiskType = (Get-Partition -DriveLetter $Letter | Get-PhysicalDisk -ErrorAction Stop).MediaType
                if ($DiskType -eq 'SSD') { Optimize-Volume -DriveLetter $Letter -ReTrim -EA Stop }
                elseif ($DiskType -eq 'HDD') { Optimize-Volume -DriveLetter $Letter -Defrag -EA Stop }
                else { Optimize-Volume -DriveLetter $Letter -EA Stop }
                Write-Host "[$Letter] OK" -ForegroundColor Green
            } catch {
                Write-Host "[$Letter] skipped: $_" -ForegroundColor Yellow
            }
        }
    }
}

function Invoke-DiskSpaceAnalyzer {
    Clear-Host
    Write-Host '=== Disk Space Analyzer ===' -ForegroundColor Magenta
    $target = Read-Host "Path to analyze (default: $env:SystemDrive\)"
    if (-not $target) { $target = "$env:SystemDrive\" }
    if (-not (Test-Path $target)) {
        Write-Host 'Path not found.' -ForegroundColor Red
        return
    }

    Write-Host "`nScanning top-level folders under $target - this can take a few minutes for large folders." -ForegroundColor Cyan
    Write-WinOptLog "Disk space analysis started: $target"

    $dirs = @(Get-ChildItem -Path $target -Directory -Force -ErrorAction SilentlyContinue)
    $results = @()
    $i = 0
    foreach ($dir in $dirs) {
        $i++
        Write-Host "  [$i/$($dirs.Count)] $($dir.Name)..." -ForegroundColor Gray
        $sizeBytes = (Get-ChildItem -Path $dir.FullName -File -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if (-not $sizeBytes) { $sizeBytes = 0 }
        $results += [pscustomobject]@{ Name = $dir.Name; Bytes = [int64]$sizeBytes }
    }

    $looseBytes = (Get-ChildItem -Path $target -File -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    if ($looseBytes) {
        $results += [pscustomobject]@{ Name = '(loose files in this folder)'; Bytes = [int64]$looseBytes }
    }

    $totalBytes = [int64](($results | Measure-Object -Property Bytes -Sum).Sum)
    $top = $results | Sort-Object Bytes -Descending | Select-Object -First 20

    Clear-Host
    Write-Host "=== Disk Space Analyzer: $target ===" -ForegroundColor Magenta
    Write-Host "Total scanned: $([Math]::Round($totalBytes / 1GB, 2)) GB across $($dirs.Count) top-level folder(s)`n" -ForegroundColor Gray

    foreach ($r in $top) {
        $pct = if ($totalBytes -gt 0) { [Math]::Round(($r.Bytes / $totalBytes) * 100, 1) } else { 0 }
        $barLen = [Math]::Min(40, [int][Math]::Round($pct / 2.5))
        $bar = ('#' * $barLen).PadRight(40)
        $gb = [Math]::Round($r.Bytes / 1GB, 2)
        Write-Host ("{0,8:N2} GB [{1}] {2,5}%  {3}" -f $gb, $bar, $pct, $r.Name) -ForegroundColor White
    }

    Write-WinOptLog "Disk space analysis complete: $target, total $([Math]::Round($totalBytes / 1GB, 2)) GB"
}

do {
    Show-DiskTools-Menu
    $ch = Read-Host '>'
    switch ($ch) {
        '1' { Invoke-DiskRepairSuite }
        '2' { Invoke-DiskSpaceAnalyzer }
        '3' { break }
    }
    if ($ch -ne '3') { Wait-WinOptEnter }
} while ($ch -ne '3')
