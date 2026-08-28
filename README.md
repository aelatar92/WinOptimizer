# WinOptimizer v2.0

Windows maintenance toolkit — interactive PowerShell menu, logging, beginner mode, and 17 modules.

## Requirements

- Windows 10/11
- **Administrator** (run `Run.bat` as admin)
- PowerShell 5.1+
- **Winget** (for module 5 only)

## Quick start

1. Right-click **`Run.bat`** → **Run as administrator**
2. Choose a module from the menu (1–18)
3. Use **15** for UI mode (Beginner/Advanced), language, rollback, and logs

## Modules

| # | Module |
|---|--------|
| 1 | OS cleanup, restore point |
| 2 | SFC, DISM, chkdsk, SSD trim / HDD defrag |
| 3 | Gaming, DNS, privacy tweaks |
| 4 | Store, drivers, audio, print spooler |
| 5 | Winget install/update/export |
| 6 | Restore point, Defender, port audit |
| 7 | Diagnostics, health score, HTML report |
| 8 | Startup programs |
| 9 | Windows services |
| 10 | Advanced cleanup |
| 11 | Network tools |
| 12 | Backup & export |
| 13 | Battery report (laptops) |
| 14 | Task scheduler |
| 15 | Settings, rollback & language |
| 16 | Smart Profiles (Gaming, Battery, Privacy, Developer) |
| 17 | Help |
| 18 | Exit |

## Language

Switch between English and Arabic from **Settings (15) → 7**. The setting is saved to `config.json` (`language`) and takes effect immediately.

## Smart Profiles

Module 16 applies a curated bundle of existing tools in one step: a Gaming profile (Ultimate Performance plan + low-latency tweaks + cache clear), Battery Saver, Privacy/Clean, and Developer (installs the `wingetBundles.developer` apps from `config.json`). Disable it by setting `enableSmartProfiles` to `false` in `config.json`.

## Claude AI (real AI diagnostics)

Module 7 ("Smart Diagnostics") has a genuine AI-powered option (`[5] Ask Claude AI for a real expert analysis`) alongside the original rule-based checks. It sends a small JSON snapshot of your PC (OS, CPU/RAM load, free disk %, uptime, pending-reboot flag, and a few recent System log error messages — no personal files or browsing data) to the Anthropic Claude API and prints back a prioritized, plain-English diagnosis.

**Setup:**
1. Get an API key at [console.anthropic.com](https://console.anthropic.com/).
2. In WinOptimizer, go to **Settings (15) → 8 (Claude AI)**:
   - Option 1 to paste your key (input is hidden and stored **encrypted for your Windows user account** in `Data/claude_key.xml`, via `Export-Clixml`/DPAPI — never written to `config.json`, never committed to git).
   - Option 3 to enable it.
   - Option 4 to pick a model (Sonnet 5 by default; Haiku 4.5 for speed/cost, Opus 5 for the deepest analysis).
3. Alternatively, set the `ANTHROPIC_API_KEY` environment variable — it takes priority over the stored key and needs no setup step.

This is a paid API — check [Anthropic's pricing](https://www.anthropic.com/pricing) for the model you pick. Everything else in WinOptimizer keeps working exactly as before if you never touch this; `enableClaudeAI` defaults to `false`.

## Folders

| Path | Purpose |
|------|---------|
| `config.json` | UI mode, DNS, winget bundles |
| `logs/` | Daily logs |
| `Data/rollback/` | DNS & registry snapshots |
| `reports/` | HTML health reports |

## Tests

```powershell
Install-Module Pester -Scope CurrentUser -Force
Invoke-Pester -Path .\Tests\WinOptimizer.Tests.ps1
```

## Optional: Windows Terminal

Run **`Run-WT.bat`** if you use Windows Terminal (optional; `Run.bat` is the main launcher).
