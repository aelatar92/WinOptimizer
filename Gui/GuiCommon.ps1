function Import-WinOptGuiAssemblies {
    Add-Type -AssemblyName PresentationFramework -ErrorAction Stop
    Add-Type -AssemblyName PresentationCore -ErrorAction Stop
    Add-Type -AssemblyName WindowsBase -ErrorAction Stop
    Add-Type -AssemblyName System.Xaml -ErrorAction Stop
}

function New-WinOptWindowFromXaml {
    param([Parameter(Mandatory)][string]$Xaml)
    $xmlDoc = [xml]$Xaml
    $reader = New-Object System.Xml.XmlNodeReader $xmlDoc
    return [Windows.Markup.XamlReader]::Load($reader)
}

function Show-WinOptInfo {
    param([string]$Message, [string]$Title = 'WinOptimizer')
    [System.Windows.MessageBox]::Show($Message, $Title, [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null
}

function Show-WinOptWarning {
    param([string]$Message, [string]$Title = 'WinOptimizer')
    [System.Windows.MessageBox]::Show($Message, $Title, [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning) | Out-Null
}

function Show-WinOptConfirm {
    param([string]$Message, [string]$Title = 'WinOptimizer')
    $result = [System.Windows.MessageBox]::Show($Message, $Title, [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Warning)
    return $result -eq [System.Windows.MessageBoxResult]::Yes
}

function Start-WinOptModuleProcess {
    param([Parameter(Mandatory)][string]$ModulePath)
    Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoExit', '-ExecutionPolicy', 'Bypass', '-File', "`"$ModulePath`"")
}
