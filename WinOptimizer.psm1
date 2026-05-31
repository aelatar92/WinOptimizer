# WinOptimizer v2.2.0 - Root Module
# Full PowerShell Module structure for WinOptimizer

$script:ModuleRoot = $PSScriptRoot

# Load core shared functions
$commonPath = Join-Path $ModuleRoot 'Lib\Common.ps1'
if (Test-Path $commonPath) {
    . $commonPath
}

< #
.SYNOPSIS
    Main entry point for WinOptimizer interactive tool.
#>
function Start-WinOptimizer {
    [CmdletBinding()]
    param(
        [switch]$NoLogo
    )

    $mainScript = Join-Path $ModuleRoot 'Main.ps1'

    if (-not (Test-Path $mainScript)) {
        Write-Error "Main.ps1 not found. The module may be corrupted."
        return
    }

    if (-not $NoLogo) {
        Write-Host "WinOptimizer v2.2.0 - Interactive Windows Optimization Toolkit" -ForegroundColor Cyan
        Write-Host "Type 'exit' or press Ctrl+C to quit at any time." -ForegroundColor DarkGray
        Write-Host ""
    }

    & $mainScript
}

# Export useful public functions
Export-ModuleMember -Function @(
    'Start-WinOptimizer',
    'Get-WinOptSystemProfile',
    'Get-WinOptHealthScore'
)

Write-Verbose "[WinOptimizer] Module v2.2.0 loaded successfully."
