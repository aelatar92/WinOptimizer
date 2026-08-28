$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'BackupExport'

$exportDir = Join-Path $WinOptRoot 'Data\exports'
if (-not (Test-Path $exportDir)) { New-Item $exportDir -ItemType Directory | Out-Null }

Clear-Host
Write-Host '=== Backup & Export ===' -ForegroundColor Yellow
Write-Host '1. Export installed apps (winget)   2. Export network/DNS snapshot   3. Open export folder' -ForegroundColor White
$ch = Read-Host '>'

$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'

switch ($ch) {
    '1' {
        $out = Join-Path $exportDir "packages_$stamp.json"
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            & winget export -o $out --include-versions
            Write-Host "Saved: $out" -ForegroundColor Green
            Write-WinOptLog "Winget export $out"
        } else { Write-Host 'Winget not installed.' -ForegroundColor Red }
    }
    '2' {
        $out = Join-Path $exportDir "network_$stamp.json"
        $data = @()
        foreach ($a in (Get-NetAdapter | Where-Object Status -eq 'Up')) {
            $dns = (Get-DnsClientServerAddress -InterfaceAlias $a.Name -AddressFamily IPv4 -EA 0).ServerAddresses
            $data += @{ adapter = $a.Name; dns = $dns; mac = $a.MacAddress }
        }
        $data | ConvertTo-Json -Depth 4 | Set-Content $out -Encoding UTF8
        Write-Host "Saved: $out" -ForegroundColor Green
    }
    '3' { Start-Process explorer.exe $exportDir }
}

Wait-WinOptEnter
