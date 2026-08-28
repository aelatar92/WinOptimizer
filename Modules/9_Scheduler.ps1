$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'Scheduler'

$cleanTaskName = 'WinOptimizer_WeeklyTempClean'
$cleanScriptPath = Join-Path $WinOptRoot 'Modules\1_OptimizeOS.ps1'
$reportTaskName = 'WinOptimizer_WeeklyHealthReport'
$reportScriptPath = Join-Path $WinOptRoot 'Lib\ScheduledHealthReport.ps1'

function Show-Scheduler-Menu {
    Clear-Host
    Write-Host '=== Task Scheduler ===' -ForegroundColor Yellow
    $cleanTask = Get-ScheduledTask -TaskName $cleanTaskName -ErrorAction SilentlyContinue
    $reportTask = Get-ScheduledTask -TaskName $reportTaskName -ErrorAction SilentlyContinue
    Write-Host "Weekly temp clean:    $(if ($cleanTask) { 'ENABLED (Sunday 03:00)' } else { 'disabled' })" -ForegroundColor Gray
    Write-Host "Weekly health report: $(if ($reportTask) { 'ENABLED (Sunday 04:00)' } else { 'disabled' })" -ForegroundColor Gray
    Write-Host ''
    Write-Host '1. Enable weekly temp clean' -ForegroundColor White
    Write-Host '2. Disable weekly temp clean' -ForegroundColor White
    Write-Host '3. Enable weekly health report (HTML, saved to reports\)' -ForegroundColor White
    Write-Host '4. Disable weekly health report' -ForegroundColor White
    Write-Host '5. Show full task status' -ForegroundColor White
    Write-Host '6. Back' -ForegroundColor Red
}

do {
    Show-Scheduler-Menu
    $ch = Read-Host '>'

    switch ($ch) {
        '1' {
            if (-not (Confirm-WinOptRisky 'Create scheduled task running Module 1 weekly as SYSTEM?')) { break }
            $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$cleanScriptPath`" -Scheduled"
            $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 3am
            $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
            Register-ScheduledTask -TaskName $cleanTaskName -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
            Write-Host 'Weekly temp clean task registered.' -ForegroundColor Green
            Write-WinOptLog 'Scheduled weekly temp clean enabled'
        }
        '2' {
            Unregister-ScheduledTask -TaskName $cleanTaskName -Confirm:$false -ErrorAction SilentlyContinue
            Write-Host 'Weekly temp clean task removed (if it existed).' -ForegroundColor Green
        }
        '3' {
            if (-not (Confirm-WinOptRisky 'Create scheduled task generating a weekly health report as SYSTEM?')) { break }
            $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$reportScriptPath`""
            $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 4am
            $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
            Register-ScheduledTask -TaskName $reportTaskName -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
            Write-Host 'Weekly health report task registered. Reports land in the reports\ folder.' -ForegroundColor Green
            Write-WinOptLog 'Scheduled weekly health report enabled'
        }
        '4' {
            Unregister-ScheduledTask -TaskName $reportTaskName -Confirm:$false -ErrorAction SilentlyContinue
            Write-Host 'Weekly health report task removed (if it existed).' -ForegroundColor Green
        }
        '5' {
            Write-Host "`n--- $cleanTaskName ---" -ForegroundColor Cyan
            Get-ScheduledTask -TaskName $cleanTaskName -ErrorAction SilentlyContinue | Format-List *
            Write-Host "--- $reportTaskName ---" -ForegroundColor Cyan
            Get-ScheduledTask -TaskName $reportTaskName -ErrorAction SilentlyContinue | Format-List *
        }
        '6' { break }
    }
    if ($ch -ne '6') { Wait-WinOptEnter }
} while ($ch -ne '6')
