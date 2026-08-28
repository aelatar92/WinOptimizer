# WinOptimizer GUI launcher (WPF). Built and PowerShell/XAML-validated on Linux;
# never rendered here (WPF has no Linux runtime) - please report any visual/runtime
# issue and it will be fixed.
$ScriptDir = Split-Path $PSScriptRoot -Parent
$SettingsWindowPath = Join-Path $PSScriptRoot 'SettingsWindow.ps1'

. (Join-Path $ScriptDir 'Lib\Common.ps1')
. (Join-Path $PSScriptRoot 'GuiCommon.ps1')

Initialize-WinOpt -Root $ScriptDir

$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Start-Process -FilePath 'powershell.exe' -ArgumentList @('-WindowStyle', 'Hidden', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"") -Verb RunAs
    exit
}

Import-WinOptGuiAssemblies

$ModuleMap = @{
    1  = Join-Path $ScriptDir 'Modules\1_OptimizeOS.ps1'
    2  = Join-Path $ScriptDir 'Modules\2_DiskTools.ps1'
    3  = Join-Path $ScriptDir 'Modules\3_AdvancedTools.ps1'
    4  = Join-Path $ScriptDir 'Modules\4_DriversRepair.ps1'
    5  = Join-Path $ScriptDir 'Modules\5_SilentInstaller.ps1'
    6  = Join-Path $ScriptDir 'Modules\6_SecurityBackup.ps1'
    7  = Join-Path $ScriptDir 'Modules\7_AIDiagnostics.ps1'
    8  = Join-Path $ScriptDir 'Modules\8_StartupManager.ps1'
    9  = Join-Path $ScriptDir 'Modules\9_WindowsServices.ps1'
    10 = Join-Path $ScriptDir 'Modules\10_AdvancedCleanup.ps1'
    11 = Join-Path $ScriptDir 'Modules\11_NetworkTools.ps1'
    12 = Join-Path $ScriptDir 'Modules\12_BackupExport.ps1'
    13 = Join-Path $ScriptDir 'Modules\13_BatteryHealth.ps1'
    14 = Join-Path $ScriptDir 'Modules\14_Scheduler.ps1'
    16 = Join-Path $ScriptDir 'Modules\16_SmartProfiles.ps1'
}

[xml]$xamlDoc = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml/xml"
        Title="WinOptimizer" Height="620" Width="760"
        Background="#0f1419" WindowStartupLocation="CenterScreen">
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#161b22"/>
            <Setter Property="Foreground" Value="#e6edf3"/>
            <Setter Property="BorderBrush" Value="#30363d"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="8"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="FontSize" Value="13"/>
        </Style>
    </Window.Resources>
    <DockPanel Margin="10">
        <StackPanel DockPanel.Dock="Top" Orientation="Horizontal" Margin="0,0,0,10">
            <TextBlock x:Name="TxtTitle" Text="WINDOWS SYSTEM OPTIMIZER" Foreground="#58a6ff" FontSize="20" FontWeight="Bold" VerticalAlignment="Center"/>
            <TextBlock x:Name="TxtMode" Text="" Foreground="#8b949e" FontSize="13" Margin="15,0,0,0" VerticalAlignment="Center"/>
            <Button x:Name="BtnLang" Content="EN / AR" Width="90" HorizontalAlignment="Right" Margin="15,0,0,0"/>
        </StackPanel>
        <StackPanel DockPanel.Dock="Bottom" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,10,0,0">
            <Button x:Name="Btn15" Content="Settings" Width="160" Height="40"/>
            <Button x:Name="BtnHelp" Content="Help" Width="160" Height="40"/>
            <Button x:Name="BtnExit" Content="Exit" Width="160" Height="40" Background="#3b1219" Foreground="#ff8080"/>
        </StackPanel>
        <ScrollViewer VerticalScrollBarVisibility="Auto">
            <UniformGrid x:Name="ModuleGrid" Columns="4" Rows="4"/>
        </ScrollViewer>
    </DockPanel>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xamlDoc
$window = [Windows.Markup.XamlReader]::Load($reader)

$txtTitle = $window.FindName('TxtTitle')
$txtMode = $window.FindName('TxtMode')
$btnLang = $window.FindName('BtnLang')
$btn15 = $window.FindName('Btn15')
$btnHelp = $window.FindName('BtnHelp')
$btnExit = $window.FindName('BtnExit')
$moduleGrid = $window.FindName('ModuleGrid')

$moduleButtons = @{}
foreach ($num in (1..14) + 16) {
    $btn = New-Object System.Windows.Controls.Button
    $btn.Tag = $num
    $clickHandler = {
        param($src, $e)
        $path = $ModuleMap[[int]$src.Tag]
        if (Test-Path $path) {
            Start-WinOptModuleProcess -ModulePath $path
        } else {
            Show-WinOptWarning "$(T 'module_missing') $path"
        }
    }.GetNewClosure()
    $btn.Add_Click($clickHandler)
    $moduleButtons[$num] = $btn
    [void]$moduleGrid.Children.Add($btn)
}

function Update-WinOptGuiTexts {
    $window.FlowDirection = if ($script:WinOptConfig.language -eq 'ar') { 'RightToLeft' } else { 'LeftToRight' }
    $txtTitle.Text = "$(T 'menu_title') v$script:WinOptVersion"
    $txtMode.Text = "$(T 'menu_mode') $script:WinOptMode"
    foreach ($num in $moduleButtons.Keys) {
        $moduleButtons[$num].Content = (T "menu_$num")
    }
    $btn15.Content = (T 'menu_15')
    $btnHelp.Content = (T 'menu_17')
    $btnExit.Content = (T 'menu_18')
}

Update-WinOptGuiTexts

$btnLang.Add_Click({
    $script:WinOptConfig.language = if ($script:WinOptConfig.language -eq 'ar') { 'en' } else { 'ar' }
    Save-WinOptConfig
    Update-WinOptGuiTexts
}.GetNewClosure())

$btn15.Add_Click({
    . $SettingsWindowPath
    Show-WinOptSettingsWindow -Owner $window
    Update-WinOptGuiTexts
}.GetNewClosure())

$btnHelp.Add_Click({
    Show-WinOptInfo -Message "$(T 'help_line1')`n`n$(T 'help_line2')" -Title (T 'menu_17')
}.GetNewClosure())

$btnExit.Add_Click({
    Write-WinOptLog 'Application exit (GUI)'
    $window.Close()
}.GetNewClosure())

[void]$window.ShowDialog()
