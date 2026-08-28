$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'WindowsServices'

$ServiceCatalog = @(
    @{ Name = 'DiagTrack'; Desc = 'Telemetry'; Risk = 'medium' },
    @{ Name = 'wuauserv'; Desc = 'Windows Update'; Risk = 'high' },
    @{ Name = 'Spooler'; Desc = 'Print Spooler'; Risk = 'low' },
    @{ Name = 'WSearch'; Desc = 'Windows Search'; Risk = 'medium' },
    @{ Name = 'XblAuthManager'; Desc = 'Xbox Live Auth'; Risk = 'low' },
    @{ Name = 'SysMain'; Desc = 'Superfetch/SysMain'; Risk = 'medium' }
)

function Show-Services-Menu {
    Clear-Host
    Write-Host '=== Windows Services Manager ===' -ForegroundColor Yellow
    Write-Host '1. List catalog   2. Disable service   3. Start service   4. Back' -ForegroundColor White
}

do {
    Show-Services-Menu
    $c = Read-Host '>'
    switch ($c) {
        '1' {
            foreach ($s in $ServiceCatalog) {
                $svc = Get-Service -Name $s.Name -ErrorAction SilentlyContinue
                $st = if ($svc) { $svc.Status } else { 'N/A' }
                Write-Host "$($s.Name) [$st] - $($s.Desc) (risk: $($s.Risk))" -ForegroundColor Gray
            }
        }
        '2' {
            $name = Read-Host 'Service name'
            $meta = $ServiceCatalog | Where-Object Name -eq $name
            $prompt = if ($meta) { "Disable $name" } else { "Disable '$name'? It is not in the known catalog - disabling the wrong service can destabilize the system." }
            if (-not (Confirm-WinOptRisky $prompt)) { break }
            if ($script:WinOptConfig.requireRestorePointBeforeRisky) { Ensure-WinOptRestorePoint -Description "Before_Disable_$name" }
            Stop-Service -Name $name -Force -ErrorAction SilentlyContinue
            Set-Service -Name $name -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "Disabled $name" -ForegroundColor Green
            Write-WinOptLog "Service disabled: $name"
        }
        '3' {
            $name = Read-Host 'Service name'
            Set-Service -Name $name -StartupType Manual -ErrorAction SilentlyContinue
            Start-Service -Name $name -ErrorAction SilentlyContinue
            Write-Host "Started $name" -ForegroundColor Green
        }
        '4' { break }
    }
    if ($c -ne '4') { Wait-WinOptEnter }
} while ($c -ne '4')
