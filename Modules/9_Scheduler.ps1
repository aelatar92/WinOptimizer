$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'Scheduler'

$taskName = 'WinOptimizer_WeeklyTempClean'
$scriptPath = Join-Path $WinOptRoot 'Modules\1_OptimizeOS.ps1'

Clear-Host
Write-Host '=== Task Scheduler ===' -ForegroundColor Yellow
Write-Host "1. Enable weekly temp clean (Sunday 03:00)`n2. Disable scheduled task`n3. Show task status" -ForegroundColor White
$ch = Read-Host '>'

switch ($ch) {
    '1' {
        if (-not (Confirm-WinOptRisky 'Create scheduled task running Module 1 weekly as SYSTEM?')) { break }
        $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -Scheduled"
        $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 3am
        $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
        Write-Host 'Task registered.' -ForegroundColor Green
        Write-WinOptLog 'Scheduled weekly temp clean'
    }
    '2' {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host 'Task removed (if existed).' -ForegroundColor Green
    }
    '3' {
        Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue | Format-List *
    }
}
Wait-WinOptEnter
