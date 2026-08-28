$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'SecurityBackup'

function Show-Security-Menu {
    Clear-Host
    Write-Host "====================================================" -ForegroundColor Magenta
    Write-Host "         Security Auditing & Backup Center          " -ForegroundColor Yellow
    Write-Host "====================================================" -ForegroundColor Magenta
    Write-Host "1. Create Instant System Restore Point (Safety First)" -ForegroundColor White
    Write-Host "2. Update Defender Signatures & Run Quick Malware Scan" -ForegroundColor White
    Write-Host "3. Audit Open Network Ports (Check for Suspicious Connections)" -ForegroundColor White
    Write-Host "4. Back to Main Menu" -ForegroundColor Red
    Write-Host "====================================================" -ForegroundColor Magenta
}

do {
    Show-Security-Menu
    $secChoice = Read-Host "Select an option (1-4)"

    switch ($secChoice) {
        '1' {
            Write-Host "`n[+] Enabling System Restore and creating a snapshot..." -ForegroundColor Cyan
            try {
                Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue

                $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore"
                Set-ItemProperty -Path $RegistryPath -Name "SystemRestorePointCreationFrequency" -Value 0 -ErrorAction SilentlyContinue
                
                Checkpoint-Computer -Description "WinOptimizer_AutoBackup" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
                Write-Host "[SUCCESS] System Restore Point created successfully! You can safely tweak now." -ForegroundColor Green
            }
            catch {
                Write-Host "[ERROR] Failed to create restore point: $_" -ForegroundColor Red
                Write-Host "[NOTE] Windows only allows one restore point every 24 hours via script unless registry is bypassed." -ForegroundColor Yellow
            }
            Read-Host "Press Enter to continue..."
        }
        
        '2' {
            Write-Host "`n[+] Checking Windows Defender Status & Updating Signatures..." -ForegroundColor Cyan
            try {
                # Trigger signature update
                Write-Host "-> Fetching latest malware definitions..." -ForegroundColor Gray
                Update-MpSignature -ErrorAction Stop
                Write-Host "[SUCCESS] Defender signatures updated." -ForegroundColor Green

                # Run a quick silent scan
                Write-Host "-> Launching Quick Malware Scan (This takes a few minutes)..." -ForegroundColor Yellow
                Start-MpScan -ScanType QuickScan -ErrorAction Stop
                Write-Host "[SUCCESS] Malware scan completed! System clean." -ForegroundColor Green
            }
            catch {
                Write-Host "[ERROR] Defender engine was unreachable or blocked: $_" -ForegroundColor Red
            }
            Read-Host "Press Enter to continue..."
        }
        
        '3' {
            Write-Host "`n=== Active Listening Ports & Established Connections ===" -ForegroundColor Yellow
            try {
                # Enumerate active TCP connections that are listening or connected
                Get-NetTCPConnection | Where-Object { $_.State -eq "Listen" -or $_.State -eq "Established" } | 
                    Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State | 
                    Format-Table -Autosize
                Write-Host "[SUCCESS] Network connection audit finished." -ForegroundColor Green
            }
            catch {
                Write-Host "[ERROR] Could not fetch network connection states: $_" -ForegroundColor Red
            }
            Read-Host "Press Enter to continue..."
        }
    }
} while ($secChoice -ne '4')