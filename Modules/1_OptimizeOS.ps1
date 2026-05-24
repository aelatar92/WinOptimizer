param([switch]$Scheduled)

$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'OptimizeOS'

if (-not $Scheduled) { Clear-Host }
Write-Host '=== Safe OS Optimization ===' -ForegroundColor Magenta

Invoke-WinOptWithProgress 'Restore point' { Ensure-WinOptRestorePoint -Description 'WinOptimizer_Before_Cleanup' }

$TargetPaths = @(
    "$env:windir\Temp\*",
    "$env:LocalAppData\Temp\*"
)
if (-not $Scheduled) {
    if (Confirm-WinOptRisky 'Also delete C:\Prefetch\* ? (may affect boot cache)') {
        $TargetPaths += 'C:\Prefetch\*'
    }
}

foreach ($Path in $TargetPaths) {
    Invoke-WinOptWithProgress "Clean $Path" {
        Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
    }
}

Invoke-WinOptWithProgress 'DNS cache' { Clear-DnsClientCache -ErrorAction Stop }

if (-not $Scheduled) {
    if (Confirm-WinOptRisky 'Run netsh winsock reset? (reboot recommended)') {
        & netsh winsock reset | Out-Null
        Write-WinOptLog 'winsock reset'
    }
} else {
    Remove-Item "$env:windir\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LocalAppData\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Clear-DnsClientCache -ErrorAction SilentlyContinue
}

if (-not $Scheduled) { Wait-WinOptEnter }
