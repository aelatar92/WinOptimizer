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
    Write-Host "3. Restart Audio Service & Refresh Group Policy [OFFLINE]" -ForegroundColor Green
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
            
            Write-Host "`n[*] Drivers exported to: $BackupPath" -ForegroundColor Green
            Write-Host "====================================================" -ForegroundColor Cyan
            Read-Host "Press Enter to return to Repair Menu..."
        }

        '3' {
            Clear-Host
            Write-Host "====================================================" -ForegroundColor Cyan
            Write-Host "    [EXECUTING] Restart Audio Service & Refresh Group Policy" -ForegroundColor Yellow
            Write-Host "====================================================" -ForegroundColor Cyan
            Write-Host "[WHAT]  : Restarts the Windows Audio service (Audiosrv) and re-applies Group Policy (gpupdate /force)." -ForegroundColor White
            Write-Host "[WHY]   : Useful if audio stopped working or Group Policy changes haven't taken effect. Won't fix driver-specific issues (e.g. a specific audio driver crashing) - use Windows Update or Device Manager for that." -ForegroundColor White
            Write-Host "[MODE]  : OFFLINE" -ForegroundColor Green
            Write-Host "----------------------------------------------------" -ForegroundColor Gray

            Write-Host "[Step 1/2] Restarting Windows Audio service (Audiosrv)..." -ForegroundColor Cyan
            Restart-Service -Name "Audiosrv" -Force -ErrorAction SilentlyContinue
            Write-Host " -> Audiosrv restarted." -ForegroundColor Green
            Start-Sleep -Seconds 1

            Write-Host "`n[Step 2/2] Refreshing Group Policy (gpupdate /force)..." -ForegroundColor Cyan
            gpupdate /target:computer /force | Out-Null
            Write-Host " -> Group Policy refreshed." -ForegroundColor Green

            Write-Host "`n[*] Done." -ForegroundColor Green
            Write-Host "====================================================" -ForegroundColor Cyan
            Read-Host "Press Enter to return to Repair Menu..."
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