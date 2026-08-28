# WinOptimizer shared library v2.0
$script:WinOptVersion = '2.0.0'
$script:WinOptRoot = $null
$script:WinOptConfig = $null
$script:WinOptMode = 'advanced'
$script:WinOptCurrentModule = 'Core'
$script:WinOptLogPath = $null

$script:WinOptStrings = @{
    en = @{
        admin_required       = 'Administrator rights required. Run Run.bat as Administrator.'
        press_enter          = 'Press Enter to continue...'
        press_enter_menu     = 'Press Enter to return to the Main Menu...'
        invalid_choice       = 'Invalid selection.'
        module_missing       = 'Module not found:'
        module_blocked       = 'This module is hidden in Beginner mode. Switch to Advanced in Settings (15).'
        confirm_risky        = 'WARNING: This action may affect system stability. Type YES to continue:'
        restore_creating     = 'Creating system restore point...'
        restore_ok           = 'Restore point created.'
        restore_fail         = 'Could not create restore point:'
        requirements_title   = 'Startup system check'
        req_ok               = '[OK]'
        req_warn             = '[WARN]'
        req_fail             = '[FAIL]'
        log_started          = 'Session started'
        rollback_saved       = 'Rollback snapshot saved.'
        rollback_restored    = 'Rollback restored from:'
        health_score         = 'System Health Score'
        html_report_saved    = 'HTML report saved:'
        menu_title           = 'WINDOWS SYSTEM OPTIMIZER'
        menu_mode            = 'Mode:'
        menu_1               = '[1]  Safe OS Optimization & Temp Cleanup'
        menu_2               = '[2]  Disk Tools (SFC, DISM, chkdsk, Trim)'
        menu_3               = '[3]  Advanced & Gaming Tweaks'
        menu_4               = '[4]  Drivers & System Repair'
        menu_5               = '[5]  Winget Apps Installer'
        menu_6               = '[6]  Security & Restore Point'
        menu_7               = '[7]  Smart Diagnostics & Health Score'
        menu_8               = '[8]  Startup Programs Manager'
        menu_9               = '[9]  Windows Services Manager'
        menu_10              = '[10] Advanced Cleanup (Recycle, Delivery)'
        menu_11              = '[11] Network Tools (Ping, DNS, Speed)'
        menu_12              = '[12] Backup & Export'
        menu_13              = '[13] Battery Health Report'
        menu_14              = '[14] Task Scheduler'
        menu_15              = '[15] Settings (Mode, Rollback, Logs)'
        menu_16              = '[16] Smart Profiles (Gaming, Battery, Privacy, Dev)'
        menu_17              = '[17] Help Guide'
        menu_18              = '[18] Exit'
        menu_select          = 'Select option (1-18)'
        menu_beginner_note   = '(Beginner mode: options {0} only)'
        menu_exit_bye        = 'WinOptimizer v{0} - Bye!'
        help_line1           = 'Modules 1-7: core tools. 8-14: startup, services, cleanup, network, backup, battery, scheduler.'
        help_line2           = '15: settings and rollback. Beginner mode limits menu items. Logs in logs\ folder.'
        settings_title       = '=== Settings ==='
        settings_1           = '1. UI Mode (Beginner / Advanced)'
        settings_2           = '2. Toggle risky-action confirmations'
        settings_3           = '3. Restore DNS from backup'
        settings_4           = '4. Restore registry from backup'
        settings_5           = '5. Open logs folder'
        settings_6           = '6. Check for updates'
        settings_7           = '7. Language (English / Arabic)'
        settings_8           = '8. Claude AI (real AI diagnostics: API key, enable, model)'
        settings_9           = '9. Back'
        claude_menu_title    = '=== Claude AI Settings ==='
        claude_menu_status   = 'Status:'
        claude_menu_enabled  = 'ENABLED'
        claude_menu_disabled = 'DISABLED'
        claude_menu_keyset   = 'API key: configured'
        claude_menu_keymissing = 'API key: not configured'
        claude_menu_1        = '1. Set API key'
        claude_menu_2        = '2. Clear API key'
        claude_menu_3        = '3. Toggle enabled/disabled'
        claude_menu_4        = '4. Choose model'
        claude_menu_5        = '5. Back'
        claude_prompt_key    = 'Paste your Anthropic API key (input hidden, starts with sk-ant-):'
        claude_key_saved     = 'API key saved (encrypted for this Windows user).'
        claude_key_cleared   = 'API key removed.'
        claude_key_empty     = 'No key entered, nothing changed.'
        claude_toggled       = 'Claude AI is now:'
        claude_model_prompt  = '1 = Sonnet 5 (best quality)   2 = Haiku 4.5 (fastest/cheapest)   3 = Opus 5 (most capable)'
        claude_model_set     = 'Model set to:'
        profiles_title       = '=== Smart Profiles ==='
        profiles_disabled    = 'Smart Profiles are disabled in config.json (enableSmartProfiles=false).'
        profiles_gaming      = '1. Gaming Profile (Ultimate Performance + Gaming tweaks + clear game cache)'
        profiles_battery     = '2. Battery Saver Profile (Balanced power plan + close background apps)'
        profiles_privacy     = '3. Privacy / Clean Profile (Disable telemetry + Advanced Cleanup)'
        profiles_developer   = '4. Developer Profile (Install dev winget bundle)'
        profiles_back        = '5. Back'
        profiles_applying    = 'Applying profile:'
        profiles_done        = 'Profile applied.'
        ai_option_5          = '[5] Ask Claude AI for a real expert analysis --------------------- [REAL AI]'
        ai_option_6          = '[6] Back to Main Menu ------------------------------------------------ [BACK]'
        ai_claude_disabled   = 'Claude AI is not set up. Go to Settings (15) -> 8 to add your API key and enable it.'
        ai_claude_working    = 'Contacting Claude AI for a real expert analysis...'
        ai_claude_error      = 'Claude AI request failed:'
        ai_claude_title      = 'CLAUDE AI EXPERT ANALYSIS'
    }
    ar = @{
        admin_required       = 'مطلوب صلاحيات المسؤول (Administrator). شغّل Run.bat كمسؤول.'
        press_enter          = 'اضغط Enter للمتابعة...'
        press_enter_menu     = 'اضغط Enter للعودة للقائمة الرئيسية...'
        invalid_choice       = 'اختيار غير صحيح.'
        module_missing       = 'الموديول غير موجود:'
        module_blocked       = 'هذا الموديول مخفي في وضع المبتدئين. بدّل لوضع Advanced من الإعدادات (15).'
        confirm_risky        = 'تحذير: هذا الإجراء قد يؤثر على استقرار النظام. اكتب YES للمتابعة:'
        restore_creating     = 'جارٍ إنشاء نقطة استعادة للنظام...'
        restore_ok           = 'تم إنشاء نقطة الاستعادة.'
        restore_fail         = 'تعذّر إنشاء نقطة الاستعادة:'
        requirements_title   = 'فحص النظام عند البدء'
        req_ok               = '[تمام]'
        req_warn             = '[تنبيه]'
        req_fail             = '[فشل]'
        log_started          = 'بدأت الجلسة'
        rollback_saved       = 'تم حفظ نسخة الاسترجاع.'
        rollback_restored    = 'تم الاسترجاع من:'
        health_score         = 'مؤشر صحة النظام'
        html_report_saved    = 'تم حفظ تقرير HTML:'
        menu_title           = 'محسّن نظام ويندوز'
        menu_mode            = 'الوضع:'
        menu_1               = '[1]  تحسين آمن للنظام وتنظيف الملفات المؤقتة'
        menu_2               = '[2]  أدوات القرص (SFC, DISM, chkdsk, Trim)'
        menu_3               = '[3]  أدوات متقدمة وتعديلات الألعاب'
        menu_4               = '[4]  التعريفات وإصلاح النظام'
        menu_5               = '[5]  مثبّت برامج Winget'
        menu_6               = '[6]  الأمان ونقطة الاستعادة'
        menu_7               = '[7]  تشخيص ذكي ومؤشر صحة النظام'
        menu_8               = '[8]  إدارة برامج بدء التشغيل'
        menu_9               = '[9]  إدارة خدمات ويندوز'
        menu_10              = '[10] تنظيف متقدم (سلة المحذوفات، Delivery)'
        menu_11              = '[11] أدوات الشبكة (Ping, DNS, سرعة)'
        menu_12              = '[12] نسخ احتياطي وتصدير'
        menu_13              = '[13] تقرير صحة البطارية'
        menu_14              = '[14] جدولة المهام'
        menu_15              = '[15] الإعدادات (الوضع، الاسترجاع، السجلات)'
        menu_16              = '[16] البروفايلات الذكية (ألعاب، بطارية، خصوصية، مطورين)'
        menu_17              = '[17] دليل المساعدة'
        menu_18              = '[18] خروج'
        menu_select          = 'اختر رقم (1-18)'
        menu_beginner_note   = '(وضع المبتدئين: الخيارات المتاحة فقط {0})'
        menu_exit_bye        = 'WinOptimizer v{0} - إلى اللقاء!'
        help_line1           = 'الموديولات 1-7: الأدوات الأساسية. 8-14: بدء التشغيل، الخدمات، التنظيف، الشبكة، النسخ الاحتياطي، البطارية، الجدولة.'
        help_line2           = '15: الإعدادات والاسترجاع. وضع المبتدئين يقلل عناصر القائمة. السجلات في مجلد logs.'
        settings_title       = '=== الإعدادات ==='
        settings_1           = '1. وضع الواجهة (مبتدئ / متقدم)'
        settings_2           = '2. تفعيل/تعطيل تأكيد الإجراءات الخطرة'
        settings_3           = '3. استرجاع DNS من النسخة الاحتياطية'
        settings_4           = '4. استرجاع الريجستري من النسخة الاحتياطية'
        settings_5           = '5. فتح مجلد السجلات'
        settings_6           = '6. التحقق من التحديثات'
        settings_7           = '7. اللغة (English / عربي)'
        settings_8           = '8. إعدادات Claude AI (تشخيص ذكي حقيقي: مفتاح API، تفعيل، الموديل)'
        settings_9           = '9. رجوع'
        claude_menu_title    = '=== إعدادات Claude AI ==='
        claude_menu_status   = 'الحالة:'
        claude_menu_enabled  = 'مفعّل'
        claude_menu_disabled = 'معطّل'
        claude_menu_keyset   = 'مفتاح API: مضبوط'
        claude_menu_keymissing = 'مفتاح API: غير مضبوط'
        claude_menu_1        = '1. ضبط مفتاح API'
        claude_menu_2        = '2. حذف مفتاح API'
        claude_menu_3        = '3. تفعيل/تعطيل'
        claude_menu_4        = '4. اختيار الموديل'
        claude_menu_5        = '5. رجوع'
        claude_prompt_key    = 'الصق مفتاح Anthropic API (الإدخال مخفي، يبدأ بـ sk-ant-):'
        claude_key_saved     = 'تم حفظ المفتاح (مشفّر لهذا المستخدم على ويندوز).'
        claude_key_cleared   = 'تم حذف المفتاح.'
        claude_key_empty     = 'لم يتم إدخال مفتاح، لم يتغير شيء.'
        claude_toggled       = 'Claude AI الآن:'
        claude_model_prompt  = '1 = Sonnet 5 (أفضل جودة)   2 = Haiku 4.5 (أسرع وأرخص)   3 = Opus 5 (الأقوى)'
        claude_model_set     = 'تم ضبط الموديل على:'
        profiles_title       = '=== البروفايلات الذكية ==='
        profiles_disabled    = 'البروفايلات الذكية معطّلة في config.json (enableSmartProfiles=false).'
        profiles_gaming      = '1. بروفايل الألعاب (أعلى أداء + تعديلات ألعاب + تنظيف كاش الألعاب)'
        profiles_battery     = '2. بروفايل توفير البطارية (خطة طاقة متوازنة + إغلاق برامج الخلفية)'
        profiles_privacy     = '3. بروفايل الخصوصية والتنظيف (تعطيل التتبع + تنظيف متقدم)'
        profiles_developer   = '4. بروفايل المطورين (تثبيت حزمة أدوات المطورين عبر Winget)'
        profiles_back        = '5. رجوع'
        profiles_applying    = 'جارٍ تطبيق البروفايل:'
        profiles_done        = 'تم تطبيق البروفايل.'
        ai_option_5          = '[5] اسأل Claude AI تحليل خبير حقيقي --------------------------- [ذكاء اصطناعي حقيقي]'
        ai_option_6          = '[6] رجوع للقائمة الرئيسية ---------------------------------------- [رجوع]'
        ai_claude_disabled   = 'Claude AI غير مفعّل. اذهب للإعدادات (15) -> 8 عشان تضيف مفتاح API وتفعّله.'
        ai_claude_working    = 'جارٍ التواصل مع Claude AI لعمل تحليل خبير حقيقي...'
        ai_claude_error      = 'فشل طلب Claude AI:'
        ai_claude_title      = 'تحليل خبير من Claude AI'
    }
}

function Write-WinOptHost {
    param(
        [Parameter(Mandatory)][string]$Message,
        [System.ConsoleColor]$ForegroundColor = [System.ConsoleColor]::White
    )
    Write-Host $Message -ForegroundColor $ForegroundColor
}

function Initialize-WinOptConsole {
    try {
        & cmd.exe /c 'chcp 65001 >nul' 2>$null | Out-Null
        $utf8 = New-Object System.Text.UTF8Encoding $false
        [Console]::OutputEncoding = $utf8
        [Console]::InputEncoding = $utf8
    } catch {}
}

function T([string]$Key) {
    $lang = 'en'
    if ($script:WinOptConfig -and $script:WinOptConfig.language -and $script:WinOptStrings.ContainsKey($script:WinOptConfig.language)) {
        $lang = $script:WinOptConfig.language
    }
    $table = $script:WinOptStrings[$lang]
    if ($table.ContainsKey($Key)) { return $table[$Key] }
    if ($script:WinOptStrings['en'].ContainsKey($Key)) { return $script:WinOptStrings['en'][$Key] }
    return $Key
}

function Initialize-WinOpt {
    param([string]$Root)
    $script:WinOptRoot = $Root
    $logDir = Join-Path $Root 'logs'
    $dataDir = Join-Path $Root 'Data'
    $rollbackDir = Join-Path $dataDir 'rollback'
    foreach ($d in @($logDir, $dataDir, $rollbackDir, (Join-Path $Root 'reports'))) {
        if (-not (Test-Path $d)) { New-Item -Path $d -ItemType Directory -Force | Out-Null }
    }
    $script:WinOptLogPath = Join-Path $logDir ("WinOptimizer_{0:yyyy-MM-dd}.log" -f (Get-Date))
    Import-WinOptConfig
    Initialize-WinOptConsole
    Write-WinOptLog "=== $(T 'log_started') v$script:WinOptVersion | Mode=$script:WinOptMode ==="
}

function Import-WinOptConfig {
    $configPath = Join-Path $script:WinOptRoot 'config.json'
    $defaults = @{
        version = $script:WinOptVersion
        uiMode = 'advanced'
        confirmRiskyActions = $true
        requireRestorePointBeforeRisky = $true
        minFreeSpacePercentOnC = 10
        logRetentionDays = 30
        beginnerAllowedModules = @(1, 2, 6, 7, 15, 16, 17, 18)
        defaultDns = @{ primary = '1.1.1.1'; secondary = '1.0.0.1' }
        wingetBundles = @{}
        scheduledTasks = @{}
        language = 'en'
        enableSmartProfiles = $true
        enableLocalAI = $false
        autoCreateRestorePoint = $false
        enableClaudeAI = $false
        claudeModel = 'claude-sonnet-5'
    }
    if (Test-Path $configPath) {
        try {
            $loaded = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
            $script:WinOptConfig = $defaults
            foreach ($prop in $loaded.PSObject.Properties) {
                $script:WinOptConfig[$prop.Name] = $prop.Value
            }
        } catch {
            $script:WinOptConfig = $defaults
            Write-WinOptLog "Config load failed: $_" 'WARN'
        }
    } else {
        $script:WinOptConfig = $defaults
    }
    $script:WinOptMode = if ($script:WinOptConfig.uiMode -in @('beginner', 'advanced')) { $script:WinOptConfig.uiMode } else { 'advanced' }
    Remove-WinOptOldLogs
}

function Save-WinOptConfig {
    $configPath = Join-Path $script:WinOptRoot 'config.json'
    $out = [ordered]@{
        version = $script:WinOptVersion
        uiMode = $script:WinOptMode
        confirmRiskyActions = [bool]$script:WinOptConfig.confirmRiskyActions
        requireRestorePointBeforeRisky = [bool]$script:WinOptConfig.requireRestorePointBeforeRisky
        minFreeSpacePercentOnC = [int]$script:WinOptConfig.minFreeSpacePercentOnC
        logRetentionDays = [int]$script:WinOptConfig.logRetentionDays
        defaultDns = $script:WinOptConfig.defaultDns
        beginnerAllowedModules = @($script:WinOptConfig.beginnerAllowedModules)
        wingetBundles = $script:WinOptConfig.wingetBundles
        scheduledTasks = $script:WinOptConfig.scheduledTasks
        updateCheckUrl = $script:WinOptConfig.updateCheckUrl
        language = $script:WinOptConfig.language
        enableSmartProfiles = [bool]$script:WinOptConfig.enableSmartProfiles
        enableLocalAI = [bool]$script:WinOptConfig.enableLocalAI
        autoCreateRestorePoint = [bool]$script:WinOptConfig.autoCreateRestorePoint
        enableClaudeAI = [bool]$script:WinOptConfig.enableClaudeAI
        claudeModel = $script:WinOptConfig.claudeModel
    }
    $out | ConvertTo-Json -Depth 6 | Set-Content -Path $configPath -Encoding UTF8
}

function Initialize-WinOptModule {
    param([string]$ModuleName)
    $script:WinOptCurrentModule = $ModuleName
    if (-not $script:WinOptRoot) {
        $script:WinOptRoot = Split-Path $PSScriptRoot -Parent
    }
    if (-not $script:WinOptConfig) { Initialize-WinOpt -Root $script:WinOptRoot }
    Write-WinOptLog "Module entered: $ModuleName"
}

function Write-WinOptLog {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )
    if (-not $script:WinOptLogPath) { return }
    $line = "[{0:yyyy-MM-dd HH:mm:ss}] [{1}] [{2}] {3}" -f (Get-Date), $Level, $script:WinOptCurrentModule, $Message
    Add-Content -Path $script:WinOptLogPath -Value $line -Encoding UTF8 -ErrorAction SilentlyContinue
}

function Remove-WinOptOldLogs {
    $days = [int]$script:WinOptConfig.logRetentionDays
    if ($days -le 0) { return }
    $logDir = Join-Path $script:WinOptRoot 'logs'
    Get-ChildItem $logDir -Filter 'WinOptimizer_*.log' -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$days) } |
        Remove-Item -Force -ErrorAction SilentlyContinue
}

function Confirm-WinOptRisky {
    param([string]$ActionDescription)
    if (-not $script:WinOptConfig.confirmRiskyActions) { return $true }
    Write-WinOptHost "`n$ActionDescription" -ForegroundColor Yellow
    Write-WinOptHost (T 'confirm_risky') -ForegroundColor Red
    $ans = (Read-Host).Trim()
    $ok = ($ans -eq 'YES')
    Write-WinOptLog "Risk confirm '$ActionDescription' => $ok" $(if ($ok) { 'INFO' } else { 'WARN' })
    return $ok
}

function New-WinOptRestorePointCore {
    param([string]$Description = 'WinOptimizer_AutoBackup')
    Write-Host (T 'restore_creating') -ForegroundColor Cyan
    try {
        Enable-ComputerRestore -Drive 'C:\' -ErrorAction SilentlyContinue
        $reg = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
        Set-ItemProperty -Path $reg -Name 'SystemRestorePointCreationFrequency' -Value 0 -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description $Description -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop
        Write-Host (T 'restore_ok') -ForegroundColor Green
        Write-WinOptLog "Restore point: $Description"
        return $true
    } catch {
        Write-Host "$(T 'restore_fail') $_" -ForegroundColor Yellow
        Write-WinOptLog "Restore point failed: $_" 'WARN'
        return $false
    }
}

function Ensure-WinOptRestorePoint {
    param([string]$Description = 'WinOptimizer_AutoBackup')
    if (-not $script:WinOptConfig.requireRestorePointBeforeRisky) { return $true }
    return New-WinOptRestorePointCore -Description $Description
}

function Invoke-WinOptAutoRestorePoint {
    if (-not $script:WinOptConfig.autoCreateRestorePoint) { return }
    $rollbackDir = Join-Path $script:WinOptRoot 'Data\rollback'
    if (-not (Test-Path $rollbackDir)) { New-Item -Path $rollbackDir -ItemType Directory -Force | Out-Null }
    $markerFile = Join-Path $rollbackDir 'last_auto_restore.txt'
    $today = (Get-Date).ToString('yyyy-MM-dd')
    $last = $null
    if (Test-Path $markerFile) { $last = (Get-Content $markerFile -Raw -ErrorAction SilentlyContinue).Trim() }
    if ($last -eq $today) { return }
    if (New-WinOptRestorePointCore -Description 'WinOptimizer_AutoDaily') {
        Set-Content -Path $markerFile -Value $today -Encoding UTF8
    }
}

function Test-WinOptModuleAllowed {
    param([int]$ModuleNumber)
    if ($script:WinOptMode -ne 'beginner') { return $true }
    $allowed = @($script:WinOptConfig.beginnerAllowedModules)
    return $ModuleNumber -in $allowed
}

function Invoke-WinOptWithProgress {
    param(
        [string]$Activity,
        [scriptblock]$ScriptBlock
    )
    Write-Host "`n[>>] $Activity" -ForegroundColor Cyan
    Write-WinOptLog $Activity
    try {
        $result = & $ScriptBlock
        Write-Host "[OK] $Activity" -ForegroundColor Green
        return $result
    } catch {
        Write-Host "[!!] $Activity : $_" -ForegroundColor Red
        Write-WinOptLog "$Activity failed: $_" 'ERROR'
        throw
    }
}

function Test-WinOptStartupRequirements {
    Write-WinOptHost "`n========================================" -ForegroundColor Cyan
    Write-WinOptHost "  $(T 'requirements_title')" -ForegroundColor Yellow
    Write-WinOptHost "========================================" -ForegroundColor Cyan

    $os = Get-CimInstance Win32_OperatingSystem
    Write-WinOptHost "$(T 'req_ok') Windows: $($os.Caption)" -ForegroundColor Green
    Write-WinOptLog "OS: $($os.Caption)"

    $vol = Get-Volume -DriveLetter C -ErrorAction SilentlyContinue
    if ($vol -and $vol.Size -gt 0) {
        $freePct = [Math]::Round(($vol.SizeRemaining / $vol.Size) * 100, 1)
        $min = [int]$script:WinOptConfig.minFreeSpacePercentOnC
        if ($freePct -lt $min) {
            Write-WinOptHost "$(T 'req_warn') Drive C free: $freePct% (below $min%)" -ForegroundColor Yellow
        } else {
            Write-WinOptHost "$(T 'req_ok') Drive C free: $freePct%" -ForegroundColor Green
        }
    }

    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        Write-WinOptHost "$(T 'req_ok') Winget: installed" -ForegroundColor Green
    } else {
        Write-WinOptHost "$(T 'req_warn') Winget: not found (Module 5 limited)" -ForegroundColor Yellow
    }

    $psVer = $PSVersionTable.PSVersion.ToString()
    Write-WinOptHost "$(T 'req_ok') PowerShell: $psVer" -ForegroundColor Green
    Start-Sleep -Seconds 1

    Invoke-WinOptAutoRestorePoint
}

function Backup-WinOptRegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [string]$Label
    )
    $rollbackDir = Join-Path $script:WinOptRoot 'Data\rollback'
    $file = Join-Path $rollbackDir 'registry_backup.json'
    $entries = @()
    if (Test-Path $file) {
        try { $entries = Get-Content $file -Raw | ConvertFrom-Json } catch { $entries = @() }
    }
    if (-not (Test-Path $Path)) { return }
    $val = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $val) { return }
    $entries += [pscustomobject]@{
        label = $Label
        path  = $Path
        name  = $Name
        value = $val.$Name
        type  = 'Registry'
        saved = (Get-Date).ToString('o')
    }
    $entries | ConvertTo-Json -Depth 4 | Set-Content $file -Encoding UTF8
    Write-WinOptLog "Registry backup: $Path\$Name"
}

function Backup-WinOptDnsSnapshot {
    $rollbackDir = Join-Path $script:WinOptRoot 'Data\rollback'
    $file = Join-Path $rollbackDir 'dns_backup.json'
    $snap = @()
    foreach ($a in (Get-NetAdapter | Where-Object Status -eq 'Up')) {
        $dns = (Get-DnsClientServerAddress -InterfaceAlias $a.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses
        $snap += [pscustomobject]@{ alias = $a.Name; servers = @($dns) }
    }
    $snap | ConvertTo-Json -Depth 4 | Set-Content $file -Encoding UTF8
    Write-Host (T 'rollback_saved') -ForegroundColor Green
    Write-WinOptLog 'DNS snapshot saved'
}

function Restore-WinOptDnsSnapshot {
    $file = Join-Path $script:WinOptRoot 'Data\rollback\dns_backup.json'
    if (-not (Test-Path $file)) {
        Write-Host 'No DNS backup found.' -ForegroundColor Yellow
        return
    }
    $snap = Get-Content $file -Raw | ConvertFrom-Json
    foreach ($item in $snap) {
        if ($item.servers -and $item.servers.Count -gt 0) {
            Set-DnsClientServerAddress -InterfaceAlias $item.alias -ServerAddresses $item.servers -ErrorAction SilentlyContinue
        } else {
            Set-DnsClientServerAddress -InterfaceAlias $item.alias -ResetServerAddresses -ErrorAction SilentlyContinue
        }
    }
    Write-Host "$(T 'rollback_restored') $file" -ForegroundColor Green
    Write-WinOptLog 'DNS restored from backup'
}

function Restore-WinOptRegistryBackup {
    $file = Join-Path $script:WinOptRoot 'Data\rollback\registry_backup.json'
    if (-not (Test-Path $file)) {
        Write-Host 'No registry backup found.' -ForegroundColor Yellow
        return
    }
    $entries = Get-Content $file -Raw | ConvertFrom-Json
    foreach ($e in $entries) {
        if (-not (Test-Path $e.path)) { New-Item -Path $e.path -Force | Out-Null }
        Set-ItemProperty -Path $e.path -Name $e.name -Value $e.value -Force -ErrorAction SilentlyContinue
    }
    Write-Host "$(T 'rollback_restored') $file" -ForegroundColor Green
    Write-WinOptLog 'Registry restored from backup'
}

function Get-WinOptHealthScore {
    $score = 100
    $issues = @()
    $actions = @()

    $os = Get-CimInstance Win32_OperatingSystem
    $totalRam = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    $freeRam = [Math]::Round($os.FreePhysicalMemory / 1MB, 1)
    $usedPct = if ($totalRam -gt 0) { [Math]::Round((($totalRam - $freeRam) / $totalRam) * 100, 1) } else { 0 }
    if ($usedPct -gt 85) { $score -= 20; $issues += "RAM high ($usedPct%)"; $actions += @{ text = 'Run Module 1'; module = 1 } }

    $vol = Get-Volume -DriveLetter C -ErrorAction SilentlyContinue
    if ($vol -and $vol.Size -gt 0) {
        $freePct = [Math]::Round(($vol.SizeRemaining / $vol.Size) * 100, 1)
        if ($freePct -lt 15) { $score -= 25; $issues += "Disk C low ($freePct% free)"; $actions += @{ text = 'Run Module 2'; module = 2 } }
    }

    $uptime = ((Get-Date) - $os.LastBootUpTime).TotalDays
    if ($uptime -ge 7) { $score -= 10; $issues += "Uptime ${uptime:N0} days"; $actions += @{ text = 'Restart PC'; module = $null } }

    if (Test-Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') {
        $score -= 15; $issues += 'Reboot pending'; $actions += @{ text = 'Restart PC'; module = $null }
    }

    $errs = @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; Level = 2 } -MaxEvents 3 -ErrorAction SilentlyContinue)
    if ($errs.Count -ge 2) { $score -= 10; $issues += 'Recent system errors in log' }

    if ($score -lt 0) { $score = 0 }
    return @{
        Score   = $score
        Issues  = $issues
        Actions = $actions
        RamPct  = $usedPct
        DiskFreePct = if ($vol) { [Math]::Round(($vol.SizeRemaining / $vol.Size) * 100, 1) } else { $null }
    }
}

function Export-WinOptHtmlReport {
    param(
        [hashtable]$ReportData,
        [string]$Title = 'WinOptimizer Report'
    )
    $reportsDir = Join-Path $script:WinOptRoot 'reports'
    if (-not (Test-Path $reportsDir)) { New-Item $reportsDir -ItemType Directory | Out-Null }
    $file = Join-Path $reportsDir ("Report_{0:yyyyMMdd_HHmmss}.html" -f (Get-Date))
    $rows = ''
    foreach ($kv in $ReportData.GetEnumerator()) {
        $raw = if ($kv.Value -is [array]) { ($kv.Value -join ' | ') } else { "$($kv.Value)" }
        $safe = $raw.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')
        $rows += "<tr><td><b>$($kv.Key)</b></td><td>$safe</td></tr>`n"
    }
    $html = @"
<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"><title>$Title</title>
<style>body{font-family:Segoe UI,Arial;margin:2rem;background:#0f1419;color:#e6edf3}
table{border-collapse:collapse;width:100%;max-width:900px}td,th{border:1px solid #30363d;padding:10px}
th{background:#161b22}h1{color:#58a6ff}</style></head><body>
<h1>$Title</h1><p>WinOptimizer v$script:WinOptVersion - $(Get-Date)</p>
<table>$rows</table></body></html>
"@
    Set-Content -Path $file -Value $html -Encoding UTF8
    Write-Host "$(T 'html_report_saved') $file" -ForegroundColor Green
    Write-WinOptLog "HTML report: $file"
    return $file
}

function Wait-WinOptEnter {
    param([string]$Prompt)
    if (-not $Prompt) { $Prompt = T 'press_enter_menu' }
    Read-Host $Prompt
}

function Invoke-WingetCommand {
    param(
        [Parameter(Mandatory)][string[]]$WingetArgs,
        [int[]]$SuccessCodes = @(0)
    )
    & winget @WingetArgs
    $exitCode = $LASTEXITCODE
    if ($exitCode -notin $SuccessCodes) { throw "winget exited with code $exitCode" }
    return $exitCode
}

function Get-WinOptClaudeKeyPath {
    Join-Path $script:WinOptRoot 'Data\claude_key.xml'
}

function Get-WinOptClaudeApiKey {
    if ($env:ANTHROPIC_API_KEY) { return $env:ANTHROPIC_API_KEY }
    $keyFile = Get-WinOptClaudeKeyPath
    if (-not (Test-Path $keyFile)) { return $null }
    try {
        $secure = Import-Clixml -Path $keyFile
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
        try {
            return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        } finally {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    } catch {
        Write-WinOptLog "Could not read stored Claude API key: $_" 'WARN'
        return $null
    }
}

function Set-WinOptClaudeApiKey {
    param([Parameter(Mandatory)][securestring]$SecureKey)
    $dataDir = Join-Path $script:WinOptRoot 'Data'
    if (-not (Test-Path $dataDir)) { New-Item -Path $dataDir -ItemType Directory -Force | Out-Null }
    $SecureKey | Export-Clixml -Path (Get-WinOptClaudeKeyPath)
    Write-WinOptLog 'Claude API key saved (encrypted at rest for this Windows user).'
}

function Clear-WinOptClaudeApiKey {
    $keyFile = Get-WinOptClaudeKeyPath
    if (Test-Path $keyFile) { Remove-Item $keyFile -Force }
    Write-WinOptLog 'Claude API key removed.'
}

function Test-WinOptClaudeAIReady {
    return [bool]($script:WinOptConfig.enableClaudeAI -and (Get-WinOptClaudeApiKey))
}

function Invoke-WinOptClaudeAI {
    param(
        [Parameter(Mandatory)][string]$SystemPrompt,
        [Parameter(Mandatory)][string]$UserPrompt,
        [int]$MaxTokens = 800
    )
    $apiKey = Get-WinOptClaudeApiKey
    if (-not $apiKey) { throw 'No Claude API key configured. Set one in Settings (15) or the ANTHROPIC_API_KEY environment variable.' }

    $model = if ($script:WinOptConfig.claudeModel) { $script:WinOptConfig.claudeModel } else { 'claude-sonnet-5' }
    $payload = @{
        model      = $model
        max_tokens = $MaxTokens
        system     = $SystemPrompt
        messages   = @(@{ role = 'user'; content = $UserPrompt })
    } | ConvertTo-Json -Depth 8

    $headers = @{
        'x-api-key'         = $apiKey
        'anthropic-version' = '2023-06-01'
        'content-type'      = 'application/json'
    }

    $response = Invoke-RestMethod -Uri 'https://api.anthropic.com/v1/messages' -Method Post -Headers $headers -Body $payload -TimeoutSec 30
    $textBlock = $response.content | Where-Object { $_.type -eq 'text' } | Select-Object -First 1
    if (-not $textBlock) { throw 'Claude API returned no text content.' }
    return $textBlock.text
}

function Get-WinOptModuleHeader {
    $root = Split-Path $PSScriptRoot -Parent
    if (Test-Path (Join-Path $root 'Lib\Common.ps1')) {
        . (Join-Path $root 'Lib\Common.ps1')
        if (-not $script:WinOptConfig) { Initialize-WinOpt -Root $root }
    }
}
