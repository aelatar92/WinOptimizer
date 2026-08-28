# WinOptimizer Settings - WPF dialog (companion to Gui/MainWindow.ps1).
# Reuses the same Lib/Common.ps1 functions as the console Settings module (15) -
# no duplicated config/backup/Claude-key logic, only a different front end.

function Show-WinOptSettingsWindow {
    param($Owner)

    [xml]$xamlDoc = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml/xml"
        Title="WinOptimizer Settings" Height="560" Width="520"
        Background="#0f1419" WindowStartupLocation="CenterOwner" ResizeMode="NoResize">
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
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#e6edf3"/>
            <Setter Property="Margin" Value="0,6,0,6"/>
        </Style>
        <Style TargetType="RadioButton">
            <Setter Property="Foreground" Value="#e6edf3"/>
            <Setter Property="Margin" Value="0,0,15,0"/>
        </Style>
        <Style TargetType="GroupBox">
            <Setter Property="Foreground" Value="#58a6ff"/>
            <Setter Property="Margin" Value="0,10,0,0"/>
        </Style>
    </Window.Resources>
    <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="15">
        <StackPanel>
            <TextBlock Text="UI Mode" FontWeight="Bold" Margin="0,0,0,5"/>
            <StackPanel Orientation="Horizontal">
                <RadioButton x:Name="RbBeginner" Content="Beginner" GroupName="Mode"/>
                <RadioButton x:Name="RbAdvanced" Content="Advanced" GroupName="Mode"/>
            </StackPanel>

            <CheckBox x:Name="ChkConfirmRisky" Content="Confirm risky actions before running them"/>

            <TextBlock Text="Language" FontWeight="Bold" Margin="0,10,0,5"/>
            <ComboBox x:Name="CmbLanguage" Width="200" HorizontalAlignment="Left">
                <ComboBoxItem Content="English" Tag="en"/>
                <ComboBoxItem Content="Arabic (عربي)" Tag="ar"/>
            </ComboBox>

            <TextBlock Text="Rollback and logs" FontWeight="Bold" Margin="0,15,0,5"/>
            <WrapPanel>
                <Button x:Name="BtnRestoreDns" Content="Restore DNS from backup"/>
                <Button x:Name="BtnRestoreReg" Content="Restore registry from backup"/>
                <Button x:Name="BtnOpenLogs" Content="Open logs folder"/>
                <Button x:Name="BtnCheckUpdates" Content="Check for updates"/>
            </WrapPanel>

            <GroupBox Header="Claude AI (real AI diagnostics)">
                <StackPanel Margin="8">
                    <TextBlock x:Name="TxtClaudeStatus" Text="" Foreground="#8b949e" Margin="0,0,0,8"/>
                    <TextBlock Text="Anthropic API key (input hidden):"/>
                    <PasswordBox x:Name="PwdClaudeKey" Margin="0,4,0,4"/>
                    <WrapPanel>
                        <Button x:Name="BtnSaveKey" Content="Save Key"/>
                        <Button x:Name="BtnClearKey" Content="Clear Key"/>
                    </WrapPanel>
                    <CheckBox x:Name="ChkEnableClaude" Content="Enable Claude AI"/>
                    <TextBlock Text="Model:"/>
                    <ComboBox x:Name="CmbClaudeModel" Width="260" HorizontalAlignment="Left">
                        <ComboBoxItem Content="Sonnet 5 (best quality)" Tag="claude-sonnet-5"/>
                        <ComboBoxItem Content="Haiku 4.5 (fastest/cheapest)" Tag="claude-haiku-4-5-20251001"/>
                        <ComboBoxItem Content="Opus 5 (most capable)" Tag="claude-opus-5"/>
                    </ComboBox>
                </StackPanel>
            </GroupBox>

            <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,20,0,0">
                <Button x:Name="BtnSaveClose" Content="Save &amp; Close" Width="120" Background="#1f6f43"/>
                <Button x:Name="BtnCancel" Content="Cancel" Width="120"/>
            </StackPanel>
        </StackPanel>
    </ScrollViewer>
</Window>
"@

    $reader = New-Object System.Xml.XmlNodeReader $xamlDoc
    $win = [Windows.Markup.XamlReader]::Load($reader)
    if ($Owner) { $win.Owner = $Owner }

    $rbBeginner = $win.FindName('RbBeginner')
    $rbAdvanced = $win.FindName('RbAdvanced')
    $chkConfirmRisky = $win.FindName('ChkConfirmRisky')
    $cmbLanguage = $win.FindName('CmbLanguage')
    $btnRestoreDns = $win.FindName('BtnRestoreDns')
    $btnRestoreReg = $win.FindName('BtnRestoreReg')
    $btnOpenLogs = $win.FindName('BtnOpenLogs')
    $btnCheckUpdates = $win.FindName('BtnCheckUpdates')
    $txtClaudeStatus = $win.FindName('TxtClaudeStatus')
    $pwdClaudeKey = $win.FindName('PwdClaudeKey')
    $btnSaveKey = $win.FindName('BtnSaveKey')
    $btnClearKey = $win.FindName('BtnClearKey')
    $chkEnableClaude = $win.FindName('ChkEnableClaude')
    $cmbClaudeModel = $win.FindName('CmbClaudeModel')
    $btnSaveClose = $win.FindName('BtnSaveClose')
    $btnCancel = $win.FindName('BtnCancel')

    function Update-WinOptClaudeStatusText {
        $enabledText = if ($script:WinOptConfig.enableClaudeAI) { 'ENABLED' } else { 'DISABLED' }
        $keyText = if (Get-WinOptClaudeApiKey) { 'API key: configured' } else { 'API key: not configured' }
        $txtClaudeStatus.Text = "Status: $enabledText | $keyText"
    }

    if ($script:WinOptMode -eq 'beginner') { $rbBeginner.IsChecked = $true } else { $rbAdvanced.IsChecked = $true }
    $chkConfirmRisky.IsChecked = [bool]$script:WinOptConfig.confirmRiskyActions
    foreach ($item in $cmbLanguage.Items) {
        if ($item.Tag -eq $script:WinOptConfig.language) { $cmbLanguage.SelectedItem = $item }
    }
    if (-not $cmbLanguage.SelectedItem) { $cmbLanguage.SelectedIndex = 0 }
    $chkEnableClaude.IsChecked = [bool]$script:WinOptConfig.enableClaudeAI
    foreach ($item in $cmbClaudeModel.Items) {
        if ($item.Tag -eq $script:WinOptConfig.claudeModel) { $cmbClaudeModel.SelectedItem = $item }
    }
    if (-not $cmbClaudeModel.SelectedItem) { $cmbClaudeModel.SelectedIndex = 0 }
    Update-WinOptClaudeStatusText

    $btnRestoreDns.Add_Click({
        Restore-WinOptDnsSnapshot
        Show-WinOptInfo -Message 'DNS restore attempted - check the logs folder for details.'
    }.GetNewClosure())

    $btnRestoreReg.Add_Click({
        Restore-WinOptRegistryBackup
        Show-WinOptInfo -Message 'Registry restore attempted - check the logs folder for details.'
    }.GetNewClosure())

    $btnOpenLogs.Add_Click({
        $logDir = Join-Path $script:WinOptRoot 'logs'
        Start-Process explorer.exe $logDir
    }.GetNewClosure())

    $btnCheckUpdates.Add_Click({
        $url = $script:WinOptConfig.updateCheckUrl
        if (-not $url) { Show-WinOptInfo -Message 'No updateCheckUrl in config.'; return }
        try {
            $remote = Invoke-RestMethod -Uri $url -TimeoutSec 5
            if ($remote.version -and $remote.version -ne $script:WinOptVersion) {
                Show-WinOptInfo -Message "Update available: $($remote.version) (you have $script:WinOptVersion)"
            } else {
                Show-WinOptInfo -Message 'You are up to date (or could not compare).'
            }
        } catch {
            Show-WinOptWarning -Message "Could not reach update URL: $_"
        }
    }.GetNewClosure())

    $btnSaveKey.Add_Click({
        if ($pwdClaudeKey.SecurePassword.Length -eq 0) {
            Show-WinOptWarning -Message 'No key entered, nothing changed.'
        } else {
            Set-WinOptClaudeApiKey -SecureKey $pwdClaudeKey.SecurePassword
            $pwdClaudeKey.Clear()
            Update-WinOptClaudeStatusText
            Show-WinOptInfo -Message 'API key saved (encrypted for this Windows user).'
        }
    }.GetNewClosure())

    $btnClearKey.Add_Click({
        Clear-WinOptClaudeApiKey
        Update-WinOptClaudeStatusText
        Show-WinOptInfo -Message 'API key removed.'
    }.GetNewClosure())

    $btnSaveClose.Add_Click({
        $script:WinOptMode = if ($rbBeginner.IsChecked) { 'beginner' } else { 'advanced' }
        $script:WinOptConfig.uiMode = $script:WinOptMode
        $script:WinOptConfig.confirmRiskyActions = [bool]$chkConfirmRisky.IsChecked
        if ($cmbLanguage.SelectedItem) { $script:WinOptConfig.language = $cmbLanguage.SelectedItem.Tag }
        $script:WinOptConfig.enableClaudeAI = [bool]$chkEnableClaude.IsChecked
        if ($cmbClaudeModel.SelectedItem) { $script:WinOptConfig.claudeModel = $cmbClaudeModel.SelectedItem.Tag }
        Save-WinOptConfig
        $win.Close()
    }.GetNewClosure())

    $btnCancel.Add_Click({ $win.Close() }.GetNewClosure())

    [void]$win.ShowDialog()
}
