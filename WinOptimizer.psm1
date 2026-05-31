# WinOptimizer Root Module v2.2.0
# This file turns WinOptimizer into a proper PowerShell Module

$script:ModuleRoot = $PSScriptRoot

# Load common functions
$commonPath = Join-Path $ModuleRoot 'Lib\Common.ps1'
if (Test-Path $commonPath) {
    . $commonPath
}

# Export main functions
Export-ModuleMember -Function @(
    'Start-WinOptimizer',
    'Get-WinOptSystemProfile',
    'Get-WinOptHealthScore'
)

# Main entry point function
function Start-WinOptimizer {
    param(
        [switch]$Advanced
    )

    $scriptPath = Join-Path $ModuleRoot 'Main.ps1'
    if (Test-Path $scriptPath) {
        & $scriptPath
    } else {
        Write-Error "Main.ps1 not found. Please run from the module root."
    }
}

# Friendly message when module is imported
Write-Verbose "WinOptimizer v2.2.0 loaded. Use 'Start-WinOptimizer' to launch the tool."
