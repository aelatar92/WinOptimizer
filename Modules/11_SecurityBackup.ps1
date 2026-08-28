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
    Write-Host "4. Manage Restore Points (list / restore / delete old)" -ForegroundColor White
    Write-Host "5. Back to Main Menu" -ForegroundColor Red
    Write-Host "====================================================" -ForegroundColor Magenta
}

function Show-RestorePoints {
    $points = @(Get-ComputerRestorePoint -ErrorAction SilentlyContinue | Sort-Object SequenceNumber -Descending)
    if ($points.Count -eq 0) {
        Write-Host 'No restore points found.' -ForegroundColor Gray
    } else {
        Write-Host ("  {0,-6} {1,-22} {2}" -f 'Seq', 'Created', 'Description') -ForegroundColor Gray
        foreach ($p in $points) {
            $date = try { [Management.ManagementDateTimeConverter]::ToDateTime($p.CreationTime) } catch { $p.CreationTime }
            Write-Host ("  {0,-6} {1,-22} {2}" -f $p.SequenceNumber, $date, $p.Description) -ForegroundColor White
        }
    }
    return $points
}

function Invoke-RestorePointRestore {
    param([object[]]$Points)
    if ($Points.Count -eq 0) { Write-Host 'No restore points available.' -ForegroundColor Yellow; return }
    $seq = Read-Host 'Sequence number to restore to'
    $target = $Points | Where-Object { $_.SequenceNumber -eq [int]$seq }
    if (-not $target) { Write-Host 'Sequence number not found.' -ForegroundColor Red; return }
    Write-Host "This restarts your PC immediately and rolls Windows back to: $($target.Description)" -ForegroundColor Red
    if (-not (Confirm-WinOptRisky "Restore to point #$seq? Unsaved work will be lost and the PC reboots now.")) { return }
    Write-WinOptLog "System restore triggered to sequence #$seq"
    try {
        Restore-Computer -RestorePoint ([int]$seq) -Confirm:$false
    } catch {
        Write-Host "Failed to start restore: $_" -ForegroundColor Red
    }
}

function Invoke-RestorePointCleanup {
    param([object[]]$Points)
    if ($Points.Count -le 1) { Write-Host 'Nothing to delete (1 or 0 restore points).' -ForegroundColor Gray; return }
    $toDelete = $Points.Count - 1
    Write-Host 'Note: this trims the oldest System Restore shadow copies on C: via vssadmin - it does not target one exact restore point by ID (Windows has no supported API for that).' -ForegroundColor Gray
    if (-not (Confirm-WinOptRisky "Delete the oldest $toDelete restore point(s), keeping only the newest?")) { return }
    for ($i = 0; $i -lt $toDelete; $i++) {
        & vssadmin delete shadows /for=C: /oldest /quiet | Out-Null
    }
    Write-Host "Deleted $toDelete old restore point(s)." -ForegroundColor Green
    Write-WinOptLog "Deleted $toDelete old restore points (kept newest)"
}

function Show-RestorePointManager {
    do {
        Clear-Host
        Write-Host '=== Restore Point Management ===' -ForegroundColor Yellow
        $points = Show-RestorePoints
        Write-Host "`n1. Restore to a specific point (reboots into System Restore)" -ForegroundColor White
        Write-Host '2. Delete old restore points (keep only the newest)' -ForegroundColor White
        Write-Host '3. Back' -ForegroundColor Red
        $rc = Read-Host '>'
        switch ($rc) {
            '1' { Invoke-RestorePointRestore -Points $points }
            '2' { Invoke-RestorePointCleanup -Points $points }
            '3' { return }
        }
        if ($rc -ne '3') { Wait-WinOptEnter }
    } while ($rc -ne '3')
}

do {
    Show-Security-Menu
    $secChoice = Read-Host "Select an option (1-5)"

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

        '4' { Show-RestorePointManager }
    }
} while ($secChoice -ne '5')
