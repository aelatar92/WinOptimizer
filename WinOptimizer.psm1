# WinOptimizer v2.2.0 - Root Module
# Professional PowerShell Module structure

$script:ModuleRoot = $PSScriptRoot

# Dot-source the core library
$commonPath = Join-Path $ModuleRoot 'Lib\Common.ps1'
if (Test-Path $commonPath) {
    . $commonPath
    Write-Verbose "[WinOptimizer] Core library loaded."
}

# Main launcher function
<#
.SYNOPSIS
    Launches the WinOptimizer interactive menu.
.DESCRIPTION
    Starts the full interactive optimization toolkit.
#>
function Start-WinOptimizer {
    [CmdletBinding()]
    param(
        [switch]$NoLogo
    )

    $mainScript = Join-Path $ModuleRoot 'Main.ps1'

    if (-not (Test-Path $mainScript)) {
        Write-Error "Main.ps1 not found in module root."
        return
    }

    if (-not $NoLogo) {
        Write-Host "WinOptimizer v$script:WinOptVersion - Starting..." -ForegroundColor Cyan
    }

    # Execute the main interactive script
    & $mainScript
}

# Export public functions
Export-ModuleMember -Function @(
    'Start-WinOptimizer',
    'Get-WinOptSystemProfile',
    'Get-WinOptHealthScore'
)

# Optional: Auto-load message when imported
if ($MyInvocation.InvocationName -eq '.') {
    Write-Verbose "WinOptimizer module loaded successfully. Use 'Start-WinOptimizer' to begin."
}
