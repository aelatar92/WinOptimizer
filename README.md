# WinOptimizer v2.0

Windows maintenance toolkit — interactive PowerShell menu (or an optional WPF GUI), logging, beginner mode, real AI diagnostics via Claude, and 16 modules.

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

## Local AI (free, offline diagnostics via Ollama)

Don't want to pay for an API? Module 7 also has `[6] Ask Local AI (Ollama, free & offline)`, which runs the same diagnostic-analysis prompt against a model running entirely on your own PC via [Ollama](https://ollama.com) — no API key, no per-request cost, no internet needed after the model is downloaded.

**Setup:**
1. Install [Ollama](https://ollama.com) (or `winget install Ollama.Ollama`) and pull a model, e.g. `ollama pull qwen2.5:3b` (small, fast, and multilingual — a good match for this app's English/Arabic UI). Any chat-capable Ollama model works; set its exact name in step 2.
2. In WinOptimizer, go to **Settings (15) → 9 (Local AI)**:
   - Option 1 to enable it.
   - Option 2 to set the model name (must match what you pulled in Ollama, e.g. `qwen2.5:3b`, `llama3.2`, `phi3`).
   - Option 3 to test the connection to Ollama.
3. Ollama runs its own local server automatically once installed (`http://localhost:11434`) — WinOptimizer just talks to it.

`enableLocalAI` defaults to `false` and doesn't touch anything else in the app.

## GUI (experimental)

Right-click **`RunGui.bat`** → **Run as administrator** for a WPF window instead of the console menu: click any of the 16 module buttons to launch that module in its own console window (unchanged, same as running it from the text menu), or use the **Settings** button for a full graphical settings dialog (UI mode, language, rollback actions, the Claude AI panel — API key, enable toggle, model picker — and the Local AI panel — enable toggle, model name, test connection) instead of typing numbers. A language button switches English/Arabic instantly, including right-to-left layout.

`Run.bat` / `Main.ps1` (the console menu) are untouched and remain the primary, fully-tested way to use WinOptimizer — the GUI is an additional opt-in entry point under `Gui\`, not a replacement.

> **Known limitation:** this GUI was written and validated (PowerShell syntax + XAML well-formedness, both checked by the test suite) on a Linux dev machine, which has no WPF runtime to actually render or click-test it on. It has not been visually verified yet. If a window fails to open, a button doesn't do what it says, or anything looks broken, please report it with the exact error text — it'll be fixed immediately.

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

## Releases / packaging

Tagged releases are packaged and published automatically by `.github/workflows/release.yml`: it stages the end-user files (`Main.ps1`, `Run.bat`, `Run-WT.bat`, `RunGui.bat`, `Lib/`, `Modules/`, `Gui/`, `config.json`, `README.md` — `Tests/`, `.github/`, and the maintainer-only `publish-github.ps1` are left out), zips them, and publishes them as a GitHub Release asset.

**To cut a release:**
1. Bump the version in both `config.json` (`"version"`) and `Lib/Common.ps1` (`$script:WinOptVersion`) — they must match.
2. Commit that change.
3. Tag it and push the tag: `git tag v2.1.0 && git push origin v2.1.0` (tag must match the version, e.g. `v2.1.0` for version `2.1.0` — the workflow fails on purpose if they don't match).
4. CI builds `WinOptimizer-2.1.0.zip` and attaches it to a new GitHub Release for that tag, with auto-generated release notes.

You can also trigger the workflow manually (Actions tab → Release → Run workflow) to get a test build as a downloadable artifact without creating a tag or a public release.

**No code signing yet** — the packaged scripts and `.bat` launchers are unsigned, so Windows SmartScreen may show an "Unknown Publisher" warning on first run. Adding Authenticode signing is a future step once a code-signing certificate is available.
