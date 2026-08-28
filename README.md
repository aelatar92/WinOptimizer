# WinOptimizer v2.0

Windows maintenance toolkit — interactive PowerShell menu (or an optional WPF GUI), logging, beginner mode, free local AI diagnostics via Ollama, and 16 modules.

## Requirements

- Windows 10/11
- **Administrator** (run `Run.bat` as admin)
- PowerShell 5.1+

Everything above is all you need for 14 of the 16 modules. Two specific modules need something extra — see the table below.

## External setup — only needed for these two modules

Everything else in WinOptimizer works with nothing beyond the requirements above; these are the only two features that reach outside the app itself.

| Module | Needs | Already have it? | If not |
|---|---|---|---|
| **13 — Winget Apps Installer** | The `winget` command | Pre-installed on Windows 10 (2004+) and Windows 11 via "App Installer". Run `winget --version` to check. | Install "App Installer" from the Microsoft Store, or see [github.com/microsoft/winget-cli](https://github.com/microsoft/winget-cli) |
| **4 — Smart Diagnostics → [5] Ask Local AI** | [Ollama](https://ollama.com) running locally, with a model pulled | Run `ollama --version`; if missing, it isn't installed | Install Ollama (`winget install Ollama.Ollama` once winget is available, or download from ollama.com), then `ollama pull qwen2.5:3b`. Full walkthrough in [Local AI](#local-ai-free-offline-diagnostics-via-ollama) below. |

The app checks for `winget` on every startup and warns if it's missing (module 13 only — nothing else is affected). Local AI has its own **Settings (16) → 8 → 3. Test connection** to verify Ollama is reachable before you rely on it.

## Quick start

1. Right-click **`Run.bat`** → **Run as administrator**
2. Choose a module from the menu (1–18)
3. Use **16** for UI mode (Beginner/Advanced), language, rollback, and logs

## Modules

| # | Module | Group |
|---|--------|-------|
| 1 | OS cleanup, restore point | Cleanup & Optimization |
| 2 | Advanced cleanup (Recycle Bin, Delivery Optimization, WinSxS) | Cleanup & Optimization |
| 3 | Disk tools (SFC, DISM, chkdsk, SSD trim / HDD defrag) | Cleanup & Optimization |
| 4 | Smart Diagnostics, health score, HTML report | Diagnostics & Health |
| 5 | Battery report (laptops) | Diagnostics & Health |
| 6 | Startup programs | System Management |
| 7 | Windows services | System Management |
| 8 | Drivers & system repair (Store, drivers, audio, print spooler) | System Management |
| 9 | Task scheduler | System Management |
| 10 | Network tools | Network & Security |
| 11 | Security & restore point (Defender, port audit) | Network & Security |
| 12 | Advanced & gaming tweaks (DNS, privacy) | Network & Security |
| 13 | Winget install/update/export | Apps & Backup |
| 14 | Backup & export | Apps & Backup |
| 15 | Smart Profiles (Gaming, Battery, Privacy, Developer) | Profiles & Settings |
| 16 | Settings, rollback & language | Profiles & Settings |
| 17 | Help | — |
| 18 | Exit | — |

## Language

Switch between English and Arabic from **Settings (16) → 7**. The setting is saved to `config.json` (`language`) and takes effect immediately.

## Smart Profiles

Module 15 applies a curated bundle of existing tools in one step: a Gaming profile (Ultimate Performance plan + low-latency tweaks + cache clear), Battery Saver, Privacy/Clean, and Developer (installs the `wingetBundles.developer` apps from `config.json`). Disable it by setting `enableSmartProfiles` to `false` in `config.json`.

## Audit report

**Settings (16) → 11** generates an HTML report of what WinOptimizer has actually done, drawn from every log file in `logs\`. It filters out pure session/navigation bookkeeping (session start, module entry, read-only scans) and keeps everything else — every logged action, warning, and error — so it answers "what did this tool actually change on my PC," not just "what did I click."

## Local AI (free, offline diagnostics via Ollama)

Module 4 ("Smart Diagnostics") has a genuine AI-powered option (`[5] Ask Local AI for a real expert analysis`) alongside the original rule-based checks. It sends a small JSON snapshot of your PC (OS, CPU/RAM load, free disk %, uptime, pending-reboot flag, and a few recent System log error messages — no personal files or browsing data) to a model running entirely on your own PC via [Ollama](https://ollama.com), and prints back a prioritized, plain-English diagnosis — no API key, no per-request cost, no internet needed after the model is downloaded.

**External setup required (this is the only feature in WinOptimizer that needs anything outside the app):**
1. Install [Ollama](https://ollama.com) (or `winget install Ollama.Ollama`) and pull a model, e.g. `ollama pull qwen2.5:3b` (small, fast, and multilingual — a good match for this app's English/Arabic UI). Any chat-capable Ollama model works; set its exact name in step 2.
2. In WinOptimizer, go to **Settings (16) → 8 (Local AI)**:
   - Option 1 to enable it.
   - Option 2 to set the model name (must match what you pulled in Ollama, e.g. `qwen2.5:3b`, `llama3.2`, `phi3`).
   - Option 3 to test the connection to Ollama.
3. Ollama runs its own local server automatically once installed (`http://localhost:11434`) — WinOptimizer just talks to it.

`enableLocalAI` defaults to `false`. Everything else in WinOptimizer keeps working exactly as before if you never touch this.

## GUI (experimental)

Right-click **`RunGui.bat`** → **Run as administrator** for a WPF window instead of the console menu: click any of the 15 module buttons to launch that module in its own console window (unchanged, same as running it from the text menu), or use the **Settings** button for a full graphical settings dialog (UI mode, language, rollback actions, a live log viewer, and the Local AI panel — enable toggle, model name, test connection) instead of typing numbers. A language button switches English/Arabic instantly, including right-to-left layout.

`Run.bat` / `Main.ps1` (the console menu) are untouched and remain the primary, fully-tested way to use WinOptimizer — the GUI is an additional opt-in entry point under `Gui\`, not a replacement.

Visually verified on real Windows 11 (both windows, both languages, including RTL). This caught two real bugs invisible to syntax/well-formedness checks alone: a wrong `xmlns:x` namespace URI that made `XamlReader.Load()` throw on every `x:Name` (the GUI could not open at all until fixed), and module-button text getting truncated instead of wrapping. Both are fixed; the test suite now also calls the real WPF loader, not just an XML well-formedness check, so a regression like the namespace bug can't hide again. If anything still looks or behaves wrong, please report it with the exact error text.

## Folders

| Path | Purpose |
|------|---------|
| `config.json` | UI mode, DNS, winget bundles |
| `logs/` | Daily logs |
| `Data/rollback/` | DNS & registry snapshots |
| `reports/` | HTML health reports |
| `Gui/` | WPF GUI launcher (`RunGui.bat`) |

## Tests

```powershell
Install-Module Pester -Scope CurrentUser -Force
Invoke-Pester -Path .\Tests\WinOptimizer.Tests.ps1
```

## Optional: Windows Terminal

Run **`Run-WT.bat`** if you use Windows Terminal (optional; `Run.bat` is the main launcher).

## Optional: System Tray health monitor

Run **`RunTray.bat`** to start a background tray icon that shows the live health score (the same one from Module 4's Health Score option) in its tooltip, refreshing every 30 minutes or on demand from its right-click menu. Read-only, doesn't need Administrator, doesn't change anything. Right-click it for **Refresh now**, **Open WinOptimizer**, or **Exit**.

## Releases / packaging

Tagged releases are packaged and published automatically by `.github/workflows/release.yml`: it stages the end-user files (`Main.ps1`, `Run.bat`, `Run-WT.bat`, `RunGui.bat`, `Lib/`, `Modules/`, `Gui/`, `config.json`, `README.md` — `Tests/` and `.github/` are left out), zips them, and publishes them as a GitHub Release asset.

**To cut a release:**
1. Bump the version in both `config.json` (`"version"`) and `Lib/Common.ps1` (`$script:WinOptVersion`) — they must match.
2. Commit that change.
3. Tag it and push the tag: `git tag v2.1.0 && git push origin v2.1.0` (tag must match the version, e.g. `v2.1.0` for version `2.1.0` — the workflow fails on purpose if they don't match).
4. CI builds `WinOptimizer-2.1.0.zip` and attaches it to a new GitHub Release for that tag, with auto-generated release notes.

You can also trigger the workflow manually (Actions tab → Release → Run workflow) to get a test build as a downloadable artifact without creating a tag or a public release.

**No code signing yet** — the packaged scripts and `.bat` launchers are unsigned, so Windows SmartScreen may show an "Unknown Publisher" warning on first run. Adding Authenticode signing is a future step once a code-signing certificate is available.
