$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'DiskTools'

Clear-Host
Write-Host '=== Disk Tools ===' -ForegroundColor Magenta

if (-not (Confirm-WinOptRisky 'SFC and DISM can take 30-60+ minutes. Continue?')) { Wait-WinOptEnter; return }
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

Wait-WinOptEnter
