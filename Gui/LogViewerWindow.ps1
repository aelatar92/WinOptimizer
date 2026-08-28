# WinOptimizer Log Viewer - WPF window showing the tail of today's log
# file, launched from Settings. Read-only; "Open Folder" still exists
# for browsing older logs in Explorer.

function Show-WinOptLogViewer {
    param($Owner)

    [xml]$xamlDoc = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinOptimizer Logs" Height="520" Width="760"
        Background="#0f1419" WindowStartupLocation="CenterOwner">
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#161b22"/>
            <Setter Property="Foreground" Value="#e6edf3"/>
            <Setter Property="BorderBrush" Value="#30363d"/>
            <Setter Property="Padding" Value="6"/>
            <Setter Property="Margin" Value="3"/>
        </Style>
        <Style TargetType="TextBlock">
            <Setter Property="Foreground" Value="#e6edf3"/>
        </Style>
    </Window.Resources>
    <DockPanel Margin="12">
        <StackPanel DockPanel.Dock="Top" Orientation="Horizontal" Margin="0,0,0,10">
            <TextBlock x:Name="TxtHeader" Text="Log:" Foreground="#58a6ff" FontSize="14" FontWeight="Bold" VerticalAlignment="Center"/>
            <Button x:Name="BtnRefresh" Content="Refresh" Width="90" Margin="15,0,0,0"/>
            <Button x:Name="BtnOpenFolder" Content="Open Folder" Width="100" Margin="6,0,0,0"/>
            <Button x:Name="BtnClose" Content="Close" Width="80" Margin="6,0,0,0"/>
        </StackPanel>
        <TextBox x:Name="TxtLog" IsReadOnly="True" TextWrapping="NoWrap"
                 VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto"
                 Background="#0d1117" Foreground="#c9d1d9" BorderBrush="#30363d"
                 FontFamily="Consolas" FontSize="12"/>
    </DockPanel>
</Window>
"@

    $reader = New-Object System.Xml.XmlNodeReader $xamlDoc
    $win = [Windows.Markup.XamlReader]::Load($reader)
    if ($Owner) { $win.Owner = $Owner }

    $txtHeader = $win.FindName('TxtHeader')
    $txtLog = $win.FindName('TxtLog')
    $btnRefresh = $win.FindName('BtnRefresh')
    $btnOpenFolder = $win.FindName('BtnOpenFolder')
    $btnClose = $win.FindName('BtnClose')

    function Update-WinOptLogViewerText {
        $logDir = Join-Path $script:WinOptRoot 'logs'
        $latest = Get-ChildItem -Path $logDir -Filter '*.log' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($latest) {
            $txtHeader.Text = "Log: $($latest.Name)"
            $lines = @(Get-Content -Path $latest.FullName -Tail 400 -ErrorAction SilentlyContinue)
            $txtLog.Text = if ($lines.Count -gt 0) { $lines -join "`r`n" } else { '(empty)' }
        } else {
            $txtHeader.Text = 'Log: none found'
            $txtLog.Text = 'No log file found yet - it is created the first time WinOptimizer runs.'
        }
        # ScrollToEnd() called synchronously right after setting Text lands
        # at a stale scroll position - confirmed by live-testing: even with
        # an explicit UpdateLayout() first, the view stayed mid-file instead
        # of at the real end. Deferring it to run after the dispatcher's
        # render/layout work (ContextIdle priority) fixes it reliably.
        $txtLog.Dispatcher.BeginInvoke([Action]{ $txtLog.ScrollToEnd() }, [System.Windows.Threading.DispatcherPriority]::ContextIdle) | Out-Null
    }

    $btnRefresh.Add_Click({ Update-WinOptLogViewerText }.GetNewClosure())
    $btnOpenFolder.Add_Click({
        $logDir = Join-Path $script:WinOptRoot 'logs'
        Start-Process explorer.exe $logDir
    }.GetNewClosure())
    $btnClose.Add_Click({ $win.Close() }.GetNewClosure())

    Update-WinOptLogViewerText
    [void]$win.ShowDialog()
}
