# Non-interactive helper invoked by the "weekly health report" scheduled
# task (see Modules/9_Scheduler.ps1). Not a menu module - generates one
# HTML health report and exits. Requires nothing beyond what
# Get-WinOptHealthScore itself needs.
$ScriptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $ScriptRoot 'Lib\Common.ps1')
Initialize-WinOpt -Root $ScriptRoot

$health = Get-WinOptHealthScore
$report = @{
    Score               = $health.Score
    RAM_Used_Percent    = $health.RamPct
    Disk_C_Free_Percent = $health.DiskFreePct
    Issues              = $health.Issues
    Actions             = ($health.Actions | ForEach-Object { $_.text }) -join ' | '
}
$path = Export-WinOptHtmlReport -ReportData $report -Title 'WinOptimizer Scheduled Health Report'
Write-WinOptLog "Scheduled health report generated: $path (score $($health.Score))"
