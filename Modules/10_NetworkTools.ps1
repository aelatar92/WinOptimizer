$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'NetworkTools'

function Show-Net-Menu {
    Clear-Host
    Write-Host '=== Network Tools ===' -ForegroundColor Yellow
    Write-Host '1. Ping test   2. DNS resolution test   3. Speed test (basic download)' -ForegroundColor White
    Write-Host '4. Back' -ForegroundColor Red
}

do {
    Show-Net-Menu
    $c = Read-Host '>'
    switch ($c) {
        '1' {
            $targetHost = Read-Host 'Host (default 1.1.1.1)'
            if (-not $targetHost) { $targetHost = '1.1.1.1' }
            Test-Connection -ComputerName $targetHost -Count 4 | Format-Table -AutoSize
            Write-WinOptLog "Ping $targetHost"
        }
        '2' {
            $name = Read-Host 'Hostname (e.g. google.com)'
            Resolve-DnsName $name -ErrorAction SilentlyContinue | Format-Table
        }
        '3' {
            Write-Host 'Downloading 10MB test file from Cloudflare...' -ForegroundColor Cyan
            $url = 'https://speed.cloudflare.com/__down?bytes=10000000'
            $sw = [Diagnostics.Stopwatch]::StartNew()
            try {
                Invoke-WebRequest -Uri $url -OutFile "$env:TEMP\winopt_speedtest.dat" -UseBasicParsing
                $sw.Stop()
                $mb = 10; $sec = [Math]::Max($sw.Elapsed.TotalSeconds, 0.1)
                $mbps = [Math]::Round(($mb * 8) / $sec, 2)
                Write-Host "Approx: $mbps Mbps (10 MB in $([Math]::Round($sec,1))s)" -ForegroundColor Green
                Remove-Item "$env:TEMP\winopt_speedtest.dat" -Force -ErrorAction SilentlyContinue
            } catch { Write-Host "Speed test failed: $_" -ForegroundColor Red }
        }
        '4' { break }
    }
    if ($c -ne '4') { Wait-WinOptEnter }
} while ($c -ne '4')
