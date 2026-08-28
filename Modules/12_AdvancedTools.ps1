$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'AdvancedTools'

function Show-Advanced-Menu {
    Clear-Host
    Write-Host "====================================================" -ForegroundColor Magenta
    Write-Host "          Advanced Tools and Gaming Menu            " -ForegroundColor Yellow
    Write-Host "====================================================" -ForegroundColor Magenta
    Write-Host "1. Activate Ultimate Performance Power Plan" -ForegroundColor White
    Write-Host "2. Clear Gaming Platforms Cache (Steam, Epic, Discord)" -ForegroundColor White
    Write-Host "3. Advanced Network Optimizer & DNS Manager" -ForegroundColor White
    Write-Host "4. Disable Windows Updates and Telemetry (Privacy)" -ForegroundColor White
    Write-Host "5. Apply Low Latency & Gaming Registry Tweaks" -ForegroundColor White
    Write-Host "6. Show Saved Wi-Fi Passwords" -ForegroundColor White
    Write-Host "7. Back to Main Menu" -ForegroundColor Red
    Write-Host "====================================================" -ForegroundColor Magenta
}

do {
    Show-Advanced-Menu
    $advChoice = Read-Host "Select an option (1-7)"

    switch ($advChoice) {
        '1' {
            Write-Host "`n[+] Activating Ultimate Performance Scheme..." -ForegroundColor Cyan
            try {
                & powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
                & powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
                Write-Host "[SUCCESS] Ultimate Performance power plan activated!" -ForegroundColor Green
            }
            catch {
                Write-Host "[ERROR] Failed to activate power plan: $_" -ForegroundColor Red
            }
            Start-Sleep -Seconds 3
        }
        
        '2' {
            Write-Host "`n[+] Closing gaming platforms and clearing cache..." -ForegroundColor Cyan
            $Processes = @("Steam", "EpicGamesLauncher", "Discord")
            foreach ($P in $Processes) { 
                Stop-Process -Name $P -Force -ErrorAction SilentlyContinue 
            }
            
            $CachePaths = @(
                "$env:LocalAppData\Steam\htmlcache\*",
                "$env:LocalAppData\EpicGamesLauncher\Saved\webcache\*",
                "$env:AppData\discord\Cache\*"
            )
            foreach ($Path in $CachePaths) {
                try {
                    Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
                    Write-Host "[SUCCESS] Cleared: $Path" -ForegroundColor Green
                }
                catch {
                    Write-Host "[SKIPPED] Active files skipped in: $Path" -ForegroundColor Yellow
                }
            }
            Start-Sleep -Seconds 3
        }
        
        '3' {
            Clear-Host
            Write-Host "====================================================" -ForegroundColor Magenta
            Write-Host "         Advanced Network & DNS Tweak Manager       " -ForegroundColor Yellow
            Write-Host "====================================================" -ForegroundColor Magenta
            Write-Host "1. Cloudflare DNS (privacy-focused, fast resolver)" -ForegroundColor White
            Write-Host "2. Google DNS (widely used, reliable resolver)" -ForegroundColor White
            Write-Host "3. Cloudflare Family (Blocks Ads & Adult Content)" -ForegroundColor White
            Write-Host "4. Keep Current DNS (Only run Network Optimization)" -ForegroundColor White
            Write-Host "====================================================" -ForegroundColor Magenta
            $dnsChoice = Read-Host "Select DNS provider option (1-4)"
            
            $Primary = ""; $Secondary = ""
            if ($dnsChoice -eq '1') { $Primary = "1.1.1.1"; $Secondary = "1.0.0.1" }
            elseif ($dnsChoice -eq '2') { $Primary = "8.8.8.8"; $Secondary = "8.8.4.4" }
            elseif ($dnsChoice -eq '3') { $Primary = "1.1.1.3"; $Secondary = "1.0.0.3" }

            if ($Primary -ne "") {
                Backup-WinOptDnsSnapshot
            }

            # Step 3.1: Apply DNS Configuration if requested
            if ($Primary -ne "") {
                Write-Host "`n[+] Applying target DNS addresses to active adapters..." -ForegroundColor Cyan
                try {
                    $Adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
                    foreach ($Adapter in $Adapters) { 
                        Set-DnsClientServerAddress -InterfaceAlias $Adapter.Name -ServerAddresses ("$Primary","$Secondary") -ErrorAction Stop
                    }
                    Write-Host "[SUCCESS] Custom DNS addresses applied successfully!" -ForegroundColor Green
                }
                catch {
                    Write-Host "[ERROR] Failed to set DNS server addresses: $_" -ForegroundColor Red
                }
            }

            # Step 3.2: Flush and Wipe DNS Cache
            Write-Host "`n[+] Flushing and wiping Windows DNS Client Cache..." -ForegroundColor Cyan
            try {
                Clear-DnsClientCache -ErrorAction SilentlyContinue
                & ipconfig /flushdns | Out-Null
                Write-Host "[SUCCESS] DNS cache successfully purged." -ForegroundColor Green
            }
            catch {
                Write-Host "[WARNING] Could not completely flush DNS cache." -ForegroundColor Yellow
            }

            # Step 3.3: Release and Renew IP Address
            Write-Host "`n[+] Releasing and Renewing IP configuration (Network may blink)..." -ForegroundColor Cyan
            try {
                & ipconfig /release | Out-Null
                Start-Sleep -Seconds 1
                & ipconfig /renew | Out-Null
                Write-Host "[SUCCESS] IP address requested and renewed successfully!" -ForegroundColor Green
            }
            catch {
                Write-Host "[ERROR] IP renewal failed: $_" -ForegroundColor Red
            }

            # Step 3.4: Reset Winsock/TCP stack (a standard "network is broken" fix,
            # not a guaranteed speed boost - see comments below)
            Write-Host "`n[+] Resetting Winsock and TCP/IP stack..." -ForegroundColor Cyan
            try {
                & netsh winsock reset | Out-Null
                & netsh int ip reset | Out-Null

                # Reset TCP auto-tuning to the Windows default (normal) - undoes any
                # prior non-default setting, does not itself add speed beyond that.
                & netsh int tcp set global autotuninglevel=normal | Out-Null

                # Legacy tweak from Windows 7/8-era gaming guides; on modern Windows
                # 10/11 TCP stacks it has no reliably measured bandwidth effect, but
                # some users still request it, so it's left as an option here.
                & netsh int tcp set global heuristics=disabled | Out-Null

                Write-Host "[SUCCESS] Winsock/TCP stack reset and auto-tuning set to default." -ForegroundColor Green
            }
            catch {
                Write-Host "[WARNING] Some network stack tweaks could not be applied." -ForegroundColor Yellow
            }

            Write-Host "`n====================================================" -ForegroundColor Magenta
            Read-Host "Network Optimization Complete! Press Enter to return..."
        }
        
        '4' {
            if (-not (Confirm-WinOptRisky 'Disable Windows Update and Telemetry services?')) { break }
            Ensure-WinOptRestorePoint -Description 'WinOptimizer_PrivacyTweaks'
            Write-Host "`n[+] Applying Privacy and Update tweaks..." -ForegroundColor Cyan
            try {
                Stop-Service -Name DiagTrack -Force -ErrorAction Stop
                Set-Service -Name DiagTrack -StartupType Disabled -ErrorAction Stop
                Write-Host "[SUCCESS] Telemetry service disabled." -ForegroundColor Green
            } catch {
                Write-Host "[SKIPPED] Telemetry service could not be modified." -ForegroundColor Yellow
            }
            try {
                Stop-Service -Name wuauserv -Force -ErrorAction Stop
                Set-Service -Name wuauserv -StartupType Disabled -ErrorAction Stop
                Write-Host "[SUCCESS] Windows Update service disabled." -ForegroundColor Green
            } catch {
                Write-Host "[SKIPPED] Windows Update service could not be modified." -ForegroundColor Yellow
            }
            Start-Sleep -Seconds 3
        }

        '5' {
            if (-not (Confirm-WinOptRisky 'Apply gaming registry tweaks to HKLM/HKCU?')) { break }
            Ensure-WinOptRestorePoint -Description 'WinOptimizer_GamingTweaks'
            Write-Host "`n[+] Applying Gaming & Low Latency Registry Tweaks..." -ForegroundColor Cyan
            try {
                $NetMultimediaPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
                Backup-WinOptRegistryValue -Path $NetMultimediaPath -Name 'NetworkThrottlingIndex' -Label 'gaming_net'
                Backup-WinOptRegistryValue -Path $NetMultimediaPath -Name 'SystemResponsiveness' -Label 'gaming_resp'
                if (-not (Test-Path $NetMultimediaPath)) { New-Item -Path $NetMultimediaPath -Force | Out-Null }
                Set-ItemProperty -Path $NetMultimediaPath -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Force
                Set-ItemProperty -Path $NetMultimediaPath -Name "SystemResponsiveness" -Value 0 -Force
                
                $GameProfilePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
                if (-not (Test-Path $GameProfilePath)) { New-Item -Path $GameProfilePath -Force | Out-Null }
                Set-ItemProperty -Path $GameProfilePath -Name "GPU Priority" -Value 8 -Force
                Set-ItemProperty -Path $GameProfilePath -Name "Priority" -Value 6 -Force
                Set-ItemProperty -Path $GameProfilePath -Name "Scheduling Category" -Value "High" -Force
                
                $GameModePath = "HKCU:\Software\Microsoft\GameBar"
                if (-not (Test-Path $GameModePath)) { New-Item -Path $GameModePath -Force | Out-Null }
                Set-ItemProperty -Path $GameModePath -Name "AllowAutoGameMode" -Value 1 -Force

                Write-Host "[SUCCESS] Gaming and Low Latency Registry tweaks applied successfully!" -ForegroundColor Green
            }
            catch {
                Write-Host "[ERROR] Failed to apply some registry tweaks: $_" -ForegroundColor Red
            }
            Start-Sleep -Seconds 4
        }
        
        '6' {
            Write-Host "`n=== Saved Wi-Fi Networks and Passwords ===" -ForegroundColor Yellow
            try {
                $WifiProfiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
                foreach ($WifiProfile in $WifiProfiles) {
                    $PasswordInfo = netsh wlan show profile name="$WifiProfile" key=clear | Select-String "Key Content"
                    if ($PasswordInfo) {
                        $Password = $PasswordInfo.ToString().Split(":")[1].Trim()
                        Write-Host "SSID: $WifiProfile  |  Password: $Password" -ForegroundColor Green
                    } else {
                        Write-Host "SSID: $WifiProfile  |  Password: [No Password Saved]" -ForegroundColor Gray
                    }
                }
            }
            catch {
                Write-Host "[ERROR] Could not retrieve Wi-Fi profiles: $_" -ForegroundColor Red
            }
            Read-Host "Press Enter to continue..."
        }
    }
} while ($advChoice -ne '7')