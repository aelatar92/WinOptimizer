# Changelog

All notable changes to WinOptimizer will be documented in this file.

## [2.2.0] - 2026-05-31

### Added
- Converted project to a proper PowerShell Module (`WinOptimizer.psd1` + `WinOptimizer.psm1`)
- New `Start-WinOptimizer` function as the recommended entry point
- `Get-WinOptSystemProfile` for automatic system profiling
- Improved module structure for better maintainability
- Added `CHANGELOG.md` and cleaned up unnecessary files
- GitHub Actions CI workflow for linting and testing

### Changed
- Major restructure for cleaner and more professional codebase
- Updated README with new installation and usage instructions
- Removed `publish-github.ps1` (not needed for end users)

### Improved
- Better error handling and logging foundation
- PSScriptAnalyzer compliance improvements (ongoing)

## [2.1.0] - Previous

- Smart Profile Detection
- Extended configuration system
- Enhanced safety and rollback features
- Foundation for Arabic UI support

[2.2.0]: https://github.com/aelatar92/WinOptimizer/compare/v2.1.0...v2.2.0
