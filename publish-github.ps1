# Run once after: gh auth login
# Creates public GitHub repo and pushes WinOptimizer

$ErrorActionPreference = 'Stop'
$gh = 'C:\Program Files\GitHub CLI\gh.exe'
if (-not (Test-Path $gh)) { $gh = 'gh' }

& $gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host 'Not logged in. Run: gh auth login' -ForegroundColor Yellow
    exit 1
}

$repoName = Read-Host 'GitHub repo name (default: WinOptimizer)'
if (-not $repoName) { $repoName = 'WinOptimizer' }

Set-Location $PSScriptRoot
& $gh repo create $repoName --public --source=. --remote=origin --push

Write-Host "`nDone! Repository URL:" -ForegroundColor Green
& $gh repo view --web 2>$null
& $gh repo view --json url -q .url
