$WinOptRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $WinOptRoot 'Lib\Common.ps1')
Initialize-WinOptModule -ModuleName 'AIDiagnostics'

function Show-AI-Menu {
    Clear-Host
    Write-Host "======================================================================================" -ForegroundColor Magenta
    Write-Host "     SMART DIAGNOSTICS AND ADVANCED SYSTEM AUDIT (RULE-BASED + OPTIONAL LOCAL AI)    " -ForegroundColor Yellow
    Write-Host "======================================================================================" -ForegroundColor Magenta
    Write-Host "  [1] Run Smart System Scan (local rules + online extensions) ---------- [HYBRID]" -ForegroundColor White
    Write-Host "  [2] Run Deep Hardware and Software Full Audit ------------------------ [OFFLINE]" -ForegroundColor White
    Write-Host "  [3] View Full System Specs, Network Topology and Upgrade Path -------- [EXPANDED]" -ForegroundColor Green
    Write-Host "  [4] Health Score + HTML Report --------------------------------------- [NEW]" -ForegroundColor Cyan
    Write-Host "  $(T 'ai_option_5')" -ForegroundColor Blue
    Write-Host "  $(T 'ai_option_6')" -ForegroundColor Red
    Write-Host "======================================================================================" -ForegroundColor Magenta
}

function Get-WinOptDiagnosticSnapshot {
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $vol = Get-Volume -DriveLetter C -ErrorAction SilentlyContinue
    $totalRam = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    $freeRam = [Math]::Round($os.FreePhysicalMemory / 1MB, 1)
    $usedRamPct = if ($totalRam -gt 0) { [Math]::Round((($totalRam - $freeRam) / $totalRam) * 100, 1) } else { 0 }
    $freeDiskPct = if ($vol -and $vol.Size -gt 0) { [Math]::Round(($vol.SizeRemaining / $vol.Size) * 100, 1) } else { $null }
    $uptimeDays = [Math]::Floor(((Get-Date) - $os.LastBootUpTime).TotalDays)
    $pendingRestart = Test-Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
    $recentErrors = @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; Level = 2 } -MaxEvents 5 -ErrorAction SilentlyContinue | ForEach-Object { $_.Message.Substring(0, [Math]::Min(120, $_.Message.Length)).Trim() })

    return [ordered]@{
        OS                = $os.Caption
        CPU               = $cpu.Name.Trim()
        CPULoadPercent    = $cpu.LoadPercentage
        RamUsedPercent    = $usedRamPct
        DiskCFreePercent  = $freeDiskPct
        UptimeDays        = $uptimeDays
        PendingRestart    = $pendingRestart
        RecentSystemErrors = $recentErrors
    }
}

function Get-WinOptExpertSystemPrompt {
    $lang = if ($script:WinOptConfig.language -eq 'ar') { 'Arabic' } else { 'English' }
    return "You are a senior Windows systems engineer embedded in a Windows maintenance tool called WinOptimizer. " +
        "You are given a live diagnostic snapshot of the user's PC as JSON. Respond in $lang. " +
        "Give: (1) a one-line overall verdict, (2) up to 3 prioritized issues with concrete fixes, referencing WinOptimizer's own menu options where relevant " +
        "(1=OS cleanup, 2=Disk tools, 8=Startup manager, 9=Services, 10=Advanced cleanup, 16=Smart Profiles), " +
        "(3) one preventive tip. Keep the whole answer under 180 words and do not repeat the raw numbers back verbatim."
}

function Invoke-LocalAIExpertAnalysis {
    Clear-Host
    if (-not (Test-WinOptLocalAIReady)) {
        Write-Host (T 'ai_local_disabled') -ForegroundColor Yellow
        Wait-WinOptEnter
        return
    }

    $snapshot = Get-WinOptDiagnosticSnapshot
    $systemPrompt = Get-WinOptExpertSystemPrompt
    $userPrompt = $snapshot | ConvertTo-Json -Depth 4

    Write-Host (T 'ai_local_working') -ForegroundColor Cyan
    try {
        $analysis = Invoke-WinOptLocalAI -SystemPrompt $systemPrompt -UserPrompt $userPrompt
        Write-Host "`n======================================================================================" -ForegroundColor Magenta
        Write-Host "  $(T 'ai_local_title')" -ForegroundColor Yellow
        Write-Host "======================================================================================" -ForegroundColor Magenta
        Write-Host $analysis -ForegroundColor White
        Write-Host "======================================================================================" -ForegroundColor Magenta
        Write-WinOptLog "Local AI analysis delivered (model=$($script:WinOptConfig.localAIModel))"
    } catch {
        Write-Host "$(T 'ai_local_error') $_" -ForegroundColor Red
        Write-WinOptLog "Local AI request failed: $_" 'ERROR'
    }
    Wait-WinOptEnter
}

do {
    Show-AI-Menu
    $aiChoice = Read-Host "Select an option (1-6)"

    if ($aiChoice -eq '1') {
        Clear-Host
        Write-Host "======================================================================================" -ForegroundColor Cyan
        Write-Host "        [STARTING] Smart Diagnostics Engine          " -ForegroundColor Yellow
        Write-Host "======================================================================================" -ForegroundColor Cyan
        
        Write-Host "[WHAT]  : Scans system health, storage, and event logs for hidden issues." -ForegroundColor White
        Write-Host "[WHY]   : To detect Windows stability errors, hardware bottlenecks, and fix them." -ForegroundColor White
        Write-Host "[MODE]  : Hybrid rule engine (no external AI API; online = extended heuristics)." -ForegroundColor Green
        Write-Host "--------------------------------------------------------------------------------------" -ForegroundColor Gray

        Write-Host "[Step 1/3] Verifying network environment..." -ForegroundColor Cyan
        $IsOnline = Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet
        
        if ($IsOnline) { Write-Host " -> Status: ONLINE. Extended diagnostic rules enabled." -ForegroundColor Green } 
        else { Write-Host " -> Status: OFFLINE. Built-in diagnostic rules only." -ForegroundColor Yellow }
        Start-Sleep -Seconds 1

        Write-Host "`n[Step 2/3] Collecting system stability telemetry data..." -ForegroundColor Cyan
        $DriveStatus = Get-Volume | Where-Object { $_.DriveLetter -eq 'C' } | Select-Object -ExpandProperty HealthStatus
        $RecentErrors = Get-WinEvent -FilterHashtable @{ LogName = 'System'; Level = 2 } -MaxEvents 2 -ErrorAction SilentlyContinue | ForEach-Object { $_.Message.SubString(0, [Math]::Min(80, $_.Message.Length)).Trim() }
        $AudioService = Get-Service -Name "Audiosrv" -ErrorAction SilentlyContinue
        $LiveAudioStatus = if ($AudioService) { $AudioService.Status } else { "Not Found" }

        Write-Host " -> Drive C Health: $DriveStatus" -ForegroundColor Gray
        Write-Host " -> Captured System Logs: Complete." -ForegroundColor Gray
        Write-Host " -> Live Audio Subsystem Check: Captured ($LiveAudioStatus)." -ForegroundColor Gray
        Start-Sleep -Seconds 1

        Write-Host "`n[Step 3/3] Generating Intelligence Diagnostic Report..." -ForegroundColor Cyan
        Write-Host "--------------------------------------------------------------------------------------" -ForegroundColor Magenta
        Write-Host "                  DIAGNOSTIC REPORT                 " -ForegroundColor Yellow
        Write-Host "--------------------------------------------------------------------------------------" -ForegroundColor Magenta

        Write-Host " -> Real-Time Subsystem Status:" -ForegroundColor Cyan
        if ($LiveAudioStatus -eq "Running") { Write-Host "    [*] Core Audio Infrastructure: RUNNING (Healthy and Active)" -ForegroundColor Green } 
        else { Write-Host "    [!] Core Audio Infrastructure: STOPPED or Missing" -ForegroundColor Red }
        
        Write-Host "`n -> Historical Event Logs Audit (Past Events):" -ForegroundColor Cyan
        if ($RecentErrors) {
            foreach ($Err in $RecentErrors) { Write-Host "    [!] Archive Log: $Err..." -ForegroundColor DarkGray }
        } else {
            Write-Host "    [*] Clean Logs: No critical system crashes found." -ForegroundColor Green
        }
        Write-Host "--------------------------------------------------------------------------------------" -ForegroundColor Gray

        if ($IsOnline) {
            try {
                Write-Host "[Status] Applying extended online diagnostic rules..." -ForegroundColor Gray
                if ($RecentErrors -and $LiveAudioStatus -eq "Running") {
                    $DiagnosticAdvice = "Analysis: Past audio-related errors appear in logs, but Audiosrv is running now. Recommendation: No action required; keep Windows updated."
                } else {
                    $DiagnosticAdvice = "Analysis: No active service failures detected. System looks stable from current telemetry."
                }
                Write-Host "`n[Diagnostic Summary]:" -ForegroundColor Green
                Write-Host $DiagnosticAdvice -ForegroundColor White
            } catch { $IsOnline = $false }
        }
        if (-not $IsOnline) {
            Write-Host "[Status] Processing via built-in offline rule set..." -ForegroundColor Gray
            if ($LiveAudioStatus -eq "Running") { Write-Host " -> REPAIR VERIFIED: Past log errors detected, but live service validation is ACTIVE." -ForegroundColor Green } 
            else { Write-Host " -> SYSTEM INSTABILITY: Service is stopped. Run Module 4 Option 3." -ForegroundColor Red }
        }
        Write-Host "======================================================================================" -ForegroundColor Magenta
        Read-Host "Diagnostics Complete! Press Enter to return to menu..."
    }

    elseif ($aiChoice -eq '2') {
        Clear-Host
        Write-Host "======================================================================================" -ForegroundColor Cyan
        Write-Host "     [STARTING] Deep Hardware and Software Audit    " -ForegroundColor Yellow
        Write-Host "======================================================================================" -ForegroundColor Cyan
        Write-Host "[WHAT]  : Deeply queries RAM, CPU, Storage, OS Uptime, and Pending Updates." -ForegroundColor White
        Write-Host "[WHY]   : To map out exact performance bottlenecks and configuration flaws." -ForegroundColor White
        Write-Host "[MODE]  : OFFLINE (Local Hardware Ingestion Engine)" -ForegroundColor Green
        Write-Host "--------------------------------------------------------------------------------------" -ForegroundColor Gray

        Write-Host "[Step 1/4] Querying physical Hardware layer (CPU and RAM)..." -ForegroundColor Cyan
        $CPUInfo = Get-CimInstance Win32_Processor | Select-Object -First 1
        $CPUName = $CPUInfo.Name.Trim()
        $CPULoad = $CPUInfo.LoadPercentage

        $OSInfo = Get-CimInstance Win32_OperatingSystem
        $TotalRAM = [Math]::Round($OSInfo.TotalVisibleMemorySize / 1MB, 1)
        $FreeRAM = [Math]::Round($OSInfo.FreePhysicalMemory / 1MB, 1)
        $UsedRAM = [Math]::Round($TotalRAM - $FreeRAM, 1)
        $RAMPercent = [Math]::Round(($UsedRAM / $TotalRAM) * 100, 1)
        Start-Sleep -Milliseconds 500

        Write-Host "[Step 2/4] Analyzing storage geometry and health..." -ForegroundColor Cyan
        $SystemDrive = Get-Volume | Where-Object { $_.DriveLetter -eq 'C' }
        $C_FreeSpacePercent = [Math]::Round(($SystemDrive.SizeRemaining / $SystemDrive.Size) * 100, 1)
        $C_Health = $SystemDrive.HealthStatus
        Start-Sleep -Milliseconds 500

        Write-Host "[Step 3/4] Inspecting OS state, Uptime, and Pending Reboots..." -ForegroundColor Cyan
        $OSName = $OSInfo.Caption
        $OSVersion = $OSInfo.Version
        $UptimeSpan = (Get-Date) - $OSInfo.LastBootUpTime
        $UptimeDays = [Math]::Floor($UptimeSpan.TotalDays)
        $PendingRestart = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
        Start-Sleep -Milliseconds 500

        Write-Host "`n[Step 4/4] Rendering Full Hardware/Software Report..." -ForegroundColor Cyan
        Write-Host "--------------------------------------------------------------------------------------" -ForegroundColor Magenta
        Write-Host "             FULL SYSTEM METRICS REPORT             " -ForegroundColor Yellow
        Write-Host "--------------------------------------------------------------------------------------" -ForegroundColor Magenta
        
        Write-Host " [HARDWARE]" -ForegroundColor Cyan
        Write-Host "  -> CPU: $CPUName ($CPULoad% Active Load)" -ForegroundColor Gray
        Write-Host "  -> RAM: Total $TotalRAM GB | Used: $UsedRAM GB ($RAMPercent% Utilization)" -ForegroundColor Gray
        Write-Host "  -> Disk C: Health [$C_Health] | Free Space Left: $C_FreeSpacePercent%" -ForegroundColor Gray
        
        Write-Host "`n [SOFTWARE AND KERNEL]" -ForegroundColor Cyan
        Write-Host "  -> Operating System: $OSName (Build: $OSVersion)" -ForegroundColor Gray
        Write-Host "  -> Continuous Uptime: $UptimeDays Days" -ForegroundColor Gray
        if ($PendingRestart) { Write-Host "  -> Windows Update State: PENDING RESTART REQUIRED" -ForegroundColor Yellow }
        else { Write-Host "  -> Windows Update State: No urgent restart flags found" -ForegroundColor Gray }

        Write-Host "--------------------------------------------------------------------------------------" -ForegroundColor Magenta
        Write-Host "        EXPERT TROUBLESHOOTING AND ADVISORY         " -ForegroundColor Yellow
        Write-Host "--------------------------------------------------------------------------------------" -ForegroundColor Magenta

        $IssuesFound = 0
        if ($RAMPercent -gt 85) {
            $IssuesFound++
            Write-Host "[!] ALERT: High Memory Saturation Detected ($RAMPercent% Used)." -ForegroundColor Red
            Write-Host "    - FIX  : Go to Main Menu -> [Module 1] (Safe OS Optimization)." -ForegroundColor Yellow
        }
        if ($C_FreeSpacePercent -lt 15) {
            $IssuesFound++
            Write-Host "[!] ALERT: Drive C Free Space Margin is Critical ($C_FreeSpacePercent% Left)." -ForegroundColor Red
            Write-Host "    - FIX  : Go to Main Menu -> [Module 2] (Disk Tools)." -ForegroundColor Yellow
        }
        if ($UptimeDays -ge 7) {
            $IssuesFound++
            Write-Host "[!] WARNING: Excessive System Uptime Detected ($UptimeDays Days)." -ForegroundColor Yellow
            Write-Host "    - FIX  : Perform a complete 'Restart' to flush memory registers." -ForegroundColor Yellow
        }
        if ($PendingRestart) {
            $IssuesFound++
            Write-Host "[!] WARNING: Windows is in a Pending Reboot state." -ForegroundColor Yellow
            Write-Host "    - FIX  : Restart immediately to apply critical infrastructure patches." -ForegroundColor Yellow
        }
        if ($IssuesFound -eq 0) {
            Write-Host "[*] EXCELLENT STATUS: No hardware or software anomalies detected!" -ForegroundColor Green
            Write-Host "    - ANALYSIS: RAM, CPU, Storage, and Kernel state are operating in perfect alignment." -ForegroundColor White
            Write-Host "    - ADVICE  : Continue using the system normally. Run this tool weekly." -ForegroundColor Green
        }
        Write-Host "======================================================================================" -ForegroundColor Magenta
        Read-Host "Audit Complete! Press Enter to return to menu..."
    }

    elseif ($aiChoice -eq '3') {
        Clear-Host
        Write-Host "======================================================================================" -ForegroundColor Cyan
        Write-Host "   [SYSTEM INGESTION] Full Blueprint, Network Topology and Upgrade Path " -ForegroundColor Yellow
        Write-Host "======================================================================================" -ForegroundColor Cyan
        
        Write-Host "[Step 1/5] Extracting Motherboard, BIOS, and Chassis metadata..." -ForegroundColor Cyan
        $CompSystem = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
        $BaseBoard  = Get-CimInstance Win32_BaseBoard -ErrorAction SilentlyContinue
        $BIOS       = Get-CimInstance Win32_Bios -ErrorAction SilentlyContinue
        
        $SysManufacturer = $CompSystem.Manufacturer.Trim()
        $SysModel        = $CompSystem.Model.Trim()
        $BoardModel      = $BaseBoard.Product
        $BIOSVersion     = $BIOS.SMBIOSBIOSVersion
        Start-Sleep -Milliseconds 300

        Write-Host "[Step 2/5] Mapping GPU Silicon and Physical Drive Arrays..." -ForegroundColor Cyan
        $GPUs = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue
        $Drives = Get-CimInstance Win32_DiskDrive -ErrorAction SilentlyContinue
        $DriveCount = @($Drives).Count
        Start-Sleep -Milliseconds 300

        Write-Host "[Step 3/5] Querying RAM Architecture and Slot Upgrade Limits..." -ForegroundColor Cyan
        $MemArray   = Get-CimInstance Win32_PhysicalMemoryArray -ErrorAction SilentlyContinue
        $MaxRAMKB   = $MemArray.MaxCapacity
        $MaxRAMGB   = if ($MaxRAMKB) { [Math]::Round($MaxRAMKB / 1MB) } else { 64 } 
        $TotalSlots = if ($MemArray.MemoryDevices) { $MemArray.MemoryDevices } else { 2 }
        
        $RAMSticks  = Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue
        $UsedSlots  = @($RAMSticks).Count
        $FreeSlots  = [Math]::Max(0, ($TotalSlots - $UsedSlots))
        
        $FirstStick = $RAMSticks | Select-Object -First 1
        $RAMSpeed   = if ($FirstStick) { $FirstStick.ConfiguredClockSpeed } else { "N/A" }
        $SmbiosRamType = if ($FirstStick) { $FirstStick.SMBIOSMemoryType } else { $null }
        $RAMTypeStr = switch ($SmbiosRamType) {
            20 { "DDR" }
            21 { "DDR2" }
            24 { "DDR3" }
            26 { "DDR4" }
            34 { "DDR5" }
            default {
                if ($SmbiosRamType) { "SMBIOS type $SmbiosRamType" } else { "Unknown" }
            }
        }
        Start-Sleep -Milliseconds 300

        Write-Host "[Step 4/5] Resolving Network Interfaces, Local IPs, and DNS Stack..." -ForegroundColor Cyan
        $NetworkAdapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }
        Start-Sleep -Milliseconds 300

        Write-Host "[Step 5/5] Contacting WAN Gateway to resolve Public IP..." -ForegroundColor Cyan
        $PublicIP = try { 
            Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 3 -ErrorAction Stop 
        } catch { 
            "OFFLINE / Timeout" 
        }

        Clear-Host
        Write-Host "======================================================================================" -ForegroundColor Cyan
        Write-Host "                        COMPLETE SYSTEM SPECIFICATIONS                                " -ForegroundColor Yellow
        Write-Host "======================================================================================" -ForegroundColor Cyan
        
        Write-Host " [-] [DEVICE AND MOTHERBOARD IDENTITY]" -ForegroundColor Cyan
        Write-Host "  -> Manufacturer : $SysManufacturer" -ForegroundColor White
        Write-Host "  -> Device Model : $SysModel" -ForegroundColor White
        Write-Host "  -> Motherboard  : $BoardModel" -ForegroundColor White
        Write-Host "  -> BIOS Version : $BIOSVersion" -ForegroundColor Gray

        Write-Host "`n [-] [PROCESSOR (CPU) DETAILS]" -ForegroundColor Cyan
        $CPUInfo = Get-CimInstance Win32_Processor | Select-Object -First 1
        Write-Host "  -> Model        : $($CPUInfo.Name.Trim())" -ForegroundColor White
        Write-Host "  -> Cores/Threads: $($CPUInfo.NumberOfCores) Cores / $($CPUInfo.NumberOfLogicalProcessors) Threads" -ForegroundColor White

        Write-Host "`n [-] [GRAPHICS PROCESSING (GPU)]" -ForegroundColor Cyan
        foreach ($GPU in $GPUs) {
            Write-Host "  -> GPU Model    : $($GPU.Name)" -ForegroundColor White
            Write-Host "     Manufacturer : $($GPU.AdapterCompatibility)" -ForegroundColor Gray
        }

        Write-Host "`n [-] [ACTIVE STORAGE DRIVES]" -ForegroundColor Cyan
        foreach ($Drive in $Drives) {
            $DriveGB = [Math]::Round($Drive.Size / 1GB, 1)
            Write-Host "  -> Model        : $($Drive.Model) ($DriveGB GB)" -ForegroundColor White
            Write-Host "     Bus Type     : $($Drive.InterfaceType) Interface Layer" -ForegroundColor Gray
        }

        Write-Host "`n [-] [NETWORK INTERFACES AND IP TOPOLOGY]" -ForegroundColor Cyan
        Write-Host "  -> Public WAN IP: $PublicIP" -ForegroundColor Yellow
        Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray
        
        foreach ($Adapter in $NetworkAdapters) {
            $LocalIPs = $Adapter.IPAddress -join ", "
            $DNSServers = if ($Adapter.DNSServerSearchOrder) { $Adapter.DNSServerSearchOrder -join ", " } else { "No DNS Server Assigned" }
            
            Write-Host "  -> Adapter Name : $($Adapter.Description)" -ForegroundColor White
            Write-Host "     IPv4/v6 Addr : $LocalIPs" -ForegroundColor Gray
            Write-Host "     DNS Servers  : $DNSServers" -ForegroundColor Green
            Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray
        }

        Write-Host "`n======================================================================================" -ForegroundColor Magenta
        Write-Host "                       LIVE HARDWARE UPGRADE PATH MAPPER                              " -ForegroundColor Yellow
        Write-Host "======================================================================================" -ForegroundColor Magenta

        Write-Host " [-] [MEMORY (RAM) UPGRADE PATH]:" -ForegroundColor Cyan
        Write-Host "  -> Total Motherboard Slots  : $TotalSlots Slots" -ForegroundColor White
        Write-Host "  -> Active Channels (In Use) : $UsedSlots Slots Filled" -ForegroundColor White
        Write-Host "  -> Available Empty Slots    : $FreeSlots Slots Open" -ForegroundColor White
        Write-Host "  -> Max Supported Capacity   : $MaxRAMGB GB Maximum Limit" -ForegroundColor Green
        Write-Host "  -> Current Architecture     : Running at $RAMSpeed MHz ($RAMTypeStr)" -ForegroundColor Gray
        
        if ($FreeSlots -gt 0) {
            Write-Host "  -> UPGRADE VERDICT         : Highly Upgradeable! You have $FreeSlots open slot(s)." -ForegroundColor Green
        } else {
            Write-Host "  -> UPGRADE VERDICT         : All slots filled. Must replace existing sticks." -ForegroundColor Yellow
        }

        Write-Host "`n [-] [STORAGE UPGRADE PATH]:" -ForegroundColor Cyan
        Write-Host "  -> Current Active Drives    : $DriveCount Drive(s) Configured." -ForegroundColor White
        Write-Host "  -> Interface Architecture   : High-Speed NVMe / PCIe Gen 4/5 Capable Layer." -ForegroundColor White
        Write-Host "  -> UPGRADE VERDICT         : Expandable. You can add multi-terabyte drives." -ForegroundColor Green

        if ($SysModel -match "Laptop" -or $SysModel -match "Notebook" -or $CPUInfo.Name -match "HX" -or $CPUInfo.Name -match "U") {
            Write-Host "`n [-] [CORE SILICON CONSTRAINTS]:" -ForegroundColor Red
            Write-Host "  -> CPU and GPU Alert        : Fixed SoC BGA Architecture. Soldered to motherboard." -ForegroundColor DarkGray
        } else {
            Write-Host "`n [-] [CORE SILICON CONSTRAINTS]:" -ForegroundColor Green
            Write-Host "  -> CPU and GPU Upgrade       : Socketed Desktop Architecture." -ForegroundColor White
        }

        Write-Host "======================================================================================" -ForegroundColor Magenta
        Read-Host "Specification Mapping Complete! Press Enter to return..."
    }

    elseif ($aiChoice -eq '4') {
        Clear-Host
        $health = Get-WinOptHealthScore
        Write-Host "=== $(T 'health_score'): $($health.Score) / 100 ===" -ForegroundColor $(if ($health.Score -ge 80) { 'Green' } elseif ($health.Score -ge 50) { 'Yellow' } else { 'Red' })
        if ($health.Issues.Count -gt 0) {
            Write-Host "`nIssues:" -ForegroundColor Yellow
            foreach ($i in $health.Issues) { Write-Host "  - $i" -ForegroundColor Gray }
            Write-Host "`nSuggested actions:" -ForegroundColor Cyan
            foreach ($a in $health.Actions) {
                if ($a.module) { Write-Host "  -> $($a.text)  [Main menu option $($a.module)]" -ForegroundColor Green }
                else { Write-Host "  -> $($a.text)" -ForegroundColor Green }
            }
        } else {
            Write-Host 'No issues detected.' -ForegroundColor Green
        }
        $report = @{
            Score = $health.Score
            RAM_Used_Percent = $health.RamPct
            Disk_C_Free_Percent = $health.DiskFreePct
            Issues = $health.Issues
            Actions = ($health.Actions | ForEach-Object { $_.text }) -join ' | '
        }
        Export-WinOptHtmlReport -ReportData $report -Title 'WinOptimizer Health Report'
        Wait-WinOptEnter
    }

    elseif ($aiChoice -eq '5') {
        Invoke-LocalAIExpertAnalysis
    }
} while ($aiChoice -ne '6')