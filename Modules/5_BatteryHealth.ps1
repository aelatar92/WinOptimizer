$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'BatteryHealth'

$battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
if (-not $battery) {
    Write-Host 'No battery detected (desktop PC?).' -ForegroundColor Yellow
    Wait-WinOptEnter
    return
}

Invoke-WinOptWithProgress 'Generating battery report' {
    $reportPath = Join-Path $env:TEMP 'battery-report.html'
    & powercfg /batteryreport /output $reportPath
    if (Test-Path $reportPath) {
        Write-Host "Report: $reportPath" -ForegroundColor Green
        $est = $battery.EstimatedChargeRemaining
        $status = $battery.BatteryStatus
        Write-Host "Charge: $est% | Status code: $status" -ForegroundColor Cyan
        Start-Process $reportPath
        Write-WinOptLog "Battery report $reportPath"
    }
}
Wait-WinOptEnter
