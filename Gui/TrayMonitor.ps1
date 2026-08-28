# WinOptimizer Tray Monitor - background System Tray icon showing the live
# health score (from the same Get-WinOptHealthScore used by Module 4).
# Read-only monitoring; does not require Administrator and never changes
# anything on the system. Launched via RunTray.bat, runs until "Exit" is
# chosen from its tray context menu.
$ScriptDir = Split-Path $PSScriptRoot -Parent
. (Join-Path $ScriptDir 'Lib\Common.ps1')
Initialize-WinOpt -Root $ScriptDir

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$script:trayIcon = New-Object System.Windows.Forms.NotifyIcon
$script:trayIcon.Icon = [System.Drawing.SystemIcons]::Information
$script:trayIcon.Text = 'WinOptimizer - checking...'
$script:trayIcon.Visible = $true

$menu = New-Object System.Windows.Forms.ContextMenuStrip
$refreshItem = $menu.Items.Add('Refresh now')
$openItem = $menu.Items.Add('Open WinOptimizer')
[void]$menu.Items.Add('-')
$exitItem = $menu.Items.Add('Exit')
$script:trayIcon.ContextMenuStrip = $menu

$script:lastScore = $null

function Update-WinOptTrayStatus {
    try {
        $health = Get-WinOptHealthScore
        $score = $health.Score
        $issueText = if ($health.Issues.Count -gt 0) { " ($($health.Issues.Count) issue(s))" } else { ' - no issues' }
        $text = "WinOptimizer: $score/100$issueText"
        # NotifyIcon.Text is capped at 63 chars on .NET Framework (Windows PowerShell 5.1),
        # unlike the 127-char limit documented for newer .NET - verified live on this runtime.
        $script:trayIcon.Text = $text.Substring(0, [Math]::Min(63, $text.Length))

        if ($score -ge 80) {
            $script:trayIcon.Icon = [System.Drawing.SystemIcons]::Information
        } elseif ($score -ge 50) {
            $script:trayIcon.Icon = [System.Drawing.SystemIcons]::Warning
        } else {
            $script:trayIcon.Icon = [System.Drawing.SystemIcons]::Error
        }

        if ($score -lt 50 -and $script:lastScore -ne $score) {
            $script:trayIcon.ShowBalloonTip(5000, 'WinOptimizer', "Health score dropped to $score/100. Open WinOptimizer (Module 4) to see issues.", [System.Windows.Forms.ToolTipIcon]::Warning)
        }
        $script:lastScore = $score
    } catch {
        $script:trayIcon.Text = 'WinOptimizer - health check failed'
        Write-WinOptLog "Tray monitor health check failed: $_" 'WARN'
    }
}

$refreshItem.Add_Click({ Update-WinOptTrayStatus })
$openItem.Add_Click({
    Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$(Join-Path $ScriptDir 'Gui\MainWindow.ps1')`"")
})
$exitItem.Add_Click({
    $script:trayIcon.Visible = $false
    $script:trayTimer.Stop()
    [System.Windows.Forms.Application]::Exit()
})
$script:trayIcon.Add_DoubleClick({ Update-WinOptTrayStatus })

$script:trayTimer = New-Object System.Windows.Forms.Timer
$script:trayTimer.Interval = 30 * 60 * 1000
$script:trayTimer.Add_Tick({ Update-WinOptTrayStatus })
$script:trayTimer.Start()

Update-WinOptTrayStatus
Write-WinOptLog 'Tray monitor started'
[System.Windows.Forms.Application]::Run()
