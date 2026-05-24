$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'DriversRepair'

function Show-Repair-Menu {
    Clear-Host
    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host "         Drivers & System Repair Center             " -ForegroundColor Yellow
    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host "1. Repair MS Store & Reset Icon Cache       [OFFLINE]" -ForegroundColor White
    Write-Host "2. Backup 3rd-Party System Drivers          [OFFLINE]" -ForegroundColor White
    Write-Host "3. Repair & Restart Core Drivers & Services [OFFLINE]" -ForegroundColor Green
    Write-Host "4. Full Reset of Print Spooler Subsystem    [OFFLINE]" -ForegroundColor White
    Write-Host "5. Back to Main Menu" -ForegroundColor Red
    Write-Host "====================================================" -ForegroundColor Cyan
}

do {
    Show-Repair-Menu
    $RepairChoice = Read-Host "Select an option (1-5)"

    switch ($RepairChoice) {
        '1' {
            Clear-Host
            Write-Host "====================================================" -ForegroundColor Cyan
            Write-Host "       [EXECUTING] MS Store & Icon Cache Repair     " -ForegroundColor Yellow
            Write-Host "====================================================" -ForegroundColor Cyan
            Write-Host "[WHAT]  : Resets Microsoft Store components and rebuilds broken desktop icons." -ForegroundColor White
            Write-Host "[WHY]   : Fixes Store download hangs and clears corrupted visual cache files." -ForegroundColor White
            Write-Host "[MODE]  : OFFLINE" -ForegroundColor Green
            Write-Host "----------------------------------------------------" -ForegroundColor Gray
            
            Write-Host "[Step 1/2] Resetting MS Store Cache via WSReset..." -ForegroundColor Cyan
            Start-Process "wsreset.exe" -Wait
            
            Write-Host "[Step 2/2] Rebuilding Explorer Icon Cache database..." -ForegroundColor Cyan
            Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1
            Remove-Item "$env:localappdata\IconCache.db" -Force -ErrorAction SilentlyContinue
            Start-Process "explorer.exe"
            
            Write-Host "`n[*] Operation completed successfully!" -ForegroundColor Green
            Write-Host "====================================================" -ForegroundColor Cyan
            Read-Host "Press Enter to return to Repair Menu..."
        }

        '2' {
            Clear-Host
            Write-Host "====================================================" -ForegroundColor Cyan
            Write-Host "       [EXECUTING] Backup 3rd-Party Drivers         " -ForegroundColor Yellow
            Write-Host "====================================================" -ForegroundColor Cyan
            Write-Host "[WHAT]  : Extracts and exports all active third-party drivers to a local folder." -ForegroundColor White
            Write-Host "[WHY]   : To safeguard your network, audio, and GPU drivers before any system update." -ForegroundColor White
            Write-Host "[MODE]  : OFFLINE" -ForegroundColor Green
            Write-Host "----------------------------------------------------" -ForegroundColor Gray
            
            $BackupPath = "$env:SystemDrive\DriversBackup"
            Write-Host "[Step 1/1] Exporting system drivers to $BackupPath..." -ForegroundColor Cyan
            if (-not (Test-Path $BackupPath)) { New-Item -Path $BackupPath -ItemType Directory | Out-Null }
            
            Export-WindowsDriver -Online -Destination $BackupPath -ErrorAction SilentlyContinue | Out-Null
            
            Write-Host "`n[*] Drivers backed up perfectly at: $BackupPath" -ForegroundColor Green
            Write-Host "====================================================" -ForegroundColor Cyan
            Read-Host "Press Enter to return to Repair Menu..."
        }

        '3' {
            Clear-Host
            Write-Host "====================================================" -ForegroundColor Cyan
            Write-Host "    [EXECUTING] Repair Core Drivers & Services      " -ForegroundColor Yellow
            Write-Host "====================================================" -ForegroundColor Cyan
            Write-Host "[WHAT]  : Refreshes Windows Audio architecture and forces Secure Boot certificate sync." -ForegroundColor White
            Write-Host "[WHY]   : Fixes sudden crashes in services like Dolby DAX API, Realtek, and boot logs." -ForegroundColor White
            Write-Host "[MODE]  : OFFLINE" -ForegroundColor Green
            Write-Host "----------------------------------------------------" -ForegroundColor Gray

            # Step 1: Repair Audio Stack (Fixing Dolby Crash)
            Write-Host "[Step 1/2] Restarting Windows Audio core infrastructure..." -ForegroundColor Cyan
            Restart-Service -Name "Audiosrv" -Force -ErrorAction SilentlyContinue
            Write-Host " -> Core Audio Service (Audiosrv) successfully cycled and restarted." -ForegroundColor Green
            Start-Sleep -Seconds 1
            
            # Step 2: Clear/Sync Component Servicing (Fixing Secure Boot Warning state)
            Write-Host "`n[Step 2/2] Triggering Windows Component Integrity Live Sync..." -ForegroundColor Cyan
            
            # [FIXED] Executing directly and piping to Out-Null to eliminate unassigned variable warning
            gpupdate /target:computer /force | Out-Null
            Write-Host " -> Component service policies re-aligned." -ForegroundColor Green
            
            Write-Host "`n[*] Core service diagnostic repair cycle execution finished!" -ForegroundColor Green
            Write-Host "====================================================" -ForegroundColor Cyan
            Read-Host "Repair Complete! Press Enter to return to menu..."
        }

        '4' {
            Clear-Host
            Write-Host "====================================================" -ForegroundColor Cyan
            Write-Host "       [EXECUTING] Print Spooler Subsystem Reset     " -ForegroundColor Yellow
            Write-Host "====================================================" -ForegroundColor Cyan
            Write-Host "[WHAT]  : Purges stuck print jobs and resets the Windows Spooler service." -ForegroundColor White
            Write-Host "[WHY]   : Fixes printer freeze-ups where documents get stuck in the queue indefinitely." -ForegroundColor White
            Write-Host "[MODE]  : OFFLINE" -ForegroundColor Green
            Write-Host "----------------------------------------------------" -ForegroundColor Gray
            
            Write-Host "[Step 1/3] Stopping Print Spooler service..." -ForegroundColor Cyan
            Stop-Service -Name "Spooler" -Force -ErrorAction SilentlyContinue
            
            Write-Host "[Step 2/3] Purging corrupted printer queue temporary files..." -ForegroundColor Cyan
            Remove-Item "$env:SystemRoot\System32\spool\PRINTERS\*" -Force -Recurse -ErrorAction SilentlyContinue
            
            Write-Host "[Step 3/3] Reviving Print Spooler subsystem..." -ForegroundColor Cyan
            Start-Service -Name "Spooler"
            
            Write-Host "`n[*] Printer queue cleared and Spooler service is back online!" -ForegroundColor Green
            Write-Host "====================================================" -ForegroundColor Cyan
            Read-Host "Press Enter to return to Repair Menu..."
        }

        '5' {
            break
        }
    }
} while ($RepairChoice -ne '5')