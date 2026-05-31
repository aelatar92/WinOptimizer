# WinOptimizer v2.2.0

**Advanced Windows Maintenance & Optimization Toolkit**

WinOptimizer is now a proper **PowerShell Module** with an interactive menu, smart diagnostics, rollback system, and profile detection.

## Installation (Recommended)

```powershell
# Clone the repository
git clone https://github.com/aelatar92/WinOptimizer.git
cd WinOptimizer

# Import as module
Import-Module .\WinOptimizer.psd1 -Force

# Launch the tool
Start-WinOptimizer
```

## Quick Start (Traditional way - still supported)

1. Right-click `Run.bat` → **Run as administrator**
2. Choose a module from the menu

## New in v2.2

- Converted to a real PowerShell Module (`WinOptimizer.psd1` + `WinOptimizer.psm1`)
- Better structure and maintainability
- `Start-WinOptimizer` function as main entry point
- Improved PSScriptAnalyzer compliance (in progress)
- Smart Profile Detection
- Enhanced configuration system

## Core Functions

| Function                    | Description                        |
|----------------------------|------------------------------------|
| `Start-WinOptimizer`       | Launches the interactive menu     |
| `Get-WinOptSystemProfile`  | Detects Gaming / Laptop / etc.    |
| `Get-WinOptHealthScore`    | Calculates system health score    |

## Configuration

Edit `config.json` to control:
- UI Mode (beginner/advanced)
- Smart Profiles
- Language (future Arabic support)
- Restore point behavior

## Project Structure (v2.2)

```
WinOptimizer/
├── .github/workflows/
├── Lib/                 # Shared functions
├── Modules/             # Individual tools (1-15)
├── Tests/
├── WinOptimizer.psd1   # Module Manifest
├── WinOptimizer.psm1   # Root Module
├── Main.ps1             # Interactive menu (legacy entry)
├── Run.bat
├── config.json
└── README.md
```

## Requirements

- Windows 10/11
- PowerShell 5.1+
- Administrator rights

## Roadmap

- Full Arabic UI support
- One-click safe fixes from diagnostics
- Health score history & trends
- Optional local AI integration

---

**WinOptimizer v2.2** — Cleaner. More Professional. Ready for the future.