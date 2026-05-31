# WinOptimizer v2.1.0

**Windows maintenance toolkit** — interactive PowerShell menu, logging, beginner/advanced mode, smart profiles, enhanced diagnostics, rollback, and excellent UX.

> **Major v2.1 Improvements Applied**: Smart System Profile Detection, Extended Config, Enhanced Safety & Logging, Arabic Readiness Foundation, Better Health Scoring foundation, and comprehensive documentation.

## Requirements

- Windows 10/11
- **Administrator** (run `Run.bat` as admin)
- PowerShell 5.1+
- **Winget** (for module 5 only)

## Quick start

1. Right-click **`Run.bat`** → **Run as administrator**
2. Choose a module from the menu (1–17)
3. Use **15** for UI mode (Beginner/Advanced), rollback, and logs

## What's New in v2.1

- **Smart Profile Detection** (`Get-WinOptSystemProfile`): Automatically detects Gaming/HighPerf, Laptop/BatterySaver, Workstation/Developer, or General and can suggest optimizations.
- **Extended `config.json`**: New keys for `enableSmartProfiles`, `enableLocalAI`, `language`, `autoCreateRestorePoint`.
- **Improved Safety**: Restore point logic respects new config, better error handling.
- **Foundation for Arabic UI**: Translation system ready for full Arabic support.
- **Enhanced Diagnostics (Module 7)**: Better structure for trends and actionable recommendations.
- **Better Logging & Config Persistence**: New fields are preserved correctly.

## Modules

| # | Module | Notes |
|---|--------|-------|
| 1 | OS cleanup, restore point | Safe & recommended |
| 2 | SFC, DISM, chkdsk, SSD trim / HDD defrag | Core repair |
| 3 | Gaming, DNS, privacy tweaks | Use with caution (Advanced mode) |
| 4 | Store, drivers, audio, print spooler | Repair tools |
| 5 | Winget install/update/export | App management |
| 6 | Restore point, Defender, port audit | Security |
| 7 | Smart Diagnostics & Health Score | **Enhanced in v2.1** - Hybrid rules + recommendations |
| 8 | Startup programs | Cleanup |
| 9 | Windows services | Management |
| 10 | Advanced cleanup | Deep clean |
| 11 | Network tools | Diagnostics |
| 12 | Backup & export | Data safety |
| 13 | Battery Health Report | Laptop focused |
| 14 | Task scheduler | Automation |
| 15 | Settings & rollback | **Important** - Mode switching, logs, rollback |
| 16 | Help | Guide |
| 17 | Exit | - |

## Folders

| Path | Purpose |
|------|---------|
| `config.json` | UI mode, DNS, winget bundles, smart profiles, language |
| `logs/` | Daily logs |
| `Data/rollback/` | DNS & registry snapshots + registry backups |
| `reports/` | HTML health reports |

## Configuration (`config.json`)

Key new options in v2.1:

```json
{
  "enableSmartProfiles": true,
  "enableLocalAI": false,
  "language": "en",
  "autoCreateRestorePoint": true
}
```

- `enableSmartProfiles`: Activates automatic profile detection on startup.
- `enableLocalAI`: Placeholder for future optional Ollama/local LLM integration in diagnostics.
- `language`: Foundation for full Arabic UI (default "en").
- `autoCreateRestorePoint`: Controls automatic restore point creation before risky actions.

## Tests

```powershell
Install-Module Pester -Scope CurrentUser -Force
Invoke-Pester -Path .\Tests\WinOptimizer.Tests.ps1
```

## Roadmap (Future Phases)

- Full Arabic UI support
- One-click safe fixes from diagnostics
- Health score history & trends in reports
- Optional local AI chat for advanced diagnostics
- PSScriptAnalyzer CI + expanded Pester tests
- Beautiful TUI with progress bars (Spectre.Console or native improvements)

## Optional: Windows Terminal

Run **`Run-WT.bat`** if you use Windows Terminal (optional; `Run.bat` is the main launcher).

---

**WinOptimizer v2.1** — Safer. Smarter. Better UX. Ready for the future.