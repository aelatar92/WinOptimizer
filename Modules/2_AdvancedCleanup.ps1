$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'AdvancedCleanup'

Clear-Host
Write-Host '=== Advanced Cleanup ===' -ForegroundColor Yellow
Write-Host '1. Empty Recycle Bin   2. Delivery Optimization cache   3. WinSxS (Component Cleanup)   4. All safe' -ForegroundColor White
$ch = Read-Host '>'

if ($ch -in @('3', '4')) {
    if (-not (Confirm-WinOptRisky 'WinSxS cleanup uses DISM and may take a long time.')) { Wait-WinOptEnter; return }
    Ensure-WinOptRestorePoint -Description 'WinOptimizer_AdvCleanup'
}

function Clear-WinOptRecycleBin {
    Invoke-WinOptWithProgress 'Recycle Bin' {
        cmd /c "rd /s /q %systemdrive%\`$Recycle.bin" 2>$null | Out-Null
    }
}

if ($ch -eq '1' -or $ch -eq '4') { Clear-WinOptRecycleBin }

if ($ch -eq '2' -or $ch -eq '4') {
    Invoke-WinOptWithProgress 'Delivery Optimization cache' {
        $p = "$env:SystemRoot\SoftwareDistribution\DeliveryOptimization\Cache"
        if (Test-Path $p) { Remove-Item "$p\*" -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

if ($ch -eq '3' -or $ch -eq '4') {
    Invoke-WinOptWithProgress 'DISM StartComponentCleanup' {
        & DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase
    }
}

Write-Host 'Done.' -ForegroundColor Green
Wait-WinOptEnter
