# Windows Profile Setup - Live Demo
# Shows all 3 profiles: Starship, CMD, ChrisTitus

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$profilePath = "$env:USERPROFILE\scripts\profiles\work\windows\Microsoft.PowerShell_profile.ps1"
$christitusPath = "$env:USERPROFILE\scripts\profiles\work\windows\Microsoft.PowerShell_profile.christitus.ps1"
$cmdAliasesPath = "$env:USERPROFILE\scripts\profiles\powershell\cmd_aliases.cmd"

function Start-DemoPane {
    param([string]$Title)
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  $($title.PadRight(46))║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

# ─────────────────────────────────────────────
# DEMO 1: Starship PowerShell
# ─────────────────────────────────────────────
Start-DemoPane -Title "PROFILE 1: Starship (PowerShell 7)"

if (-not (Test-Path $profilePath)) {
    Write-Warning "Starship profile not found at $profilePath"
} else {
    Write-Host "📂 Loading profile: Microsoft.PowerShell_profile.ps1" -ForegroundColor Yellow
    Write-Host "⚡ Initializing zoxide, starship, terminal-icons..." -ForegroundColor Gray
    Write-Host ""

    # Source the profile in a separate runspace and capture first N lines
    $welcome = pwsh -NoProfile -Command "
        . '$profilePath'
        # Just show welcome, then exit
    " 2>&1 | Out-String

    Write-Host $welcome

    Write-Host ""
    Write-Host "Available commands:" -ForegroundColor Green
    Write-Host "  ls       → eza --icons (colorful file listing)" -ForegroundColor White
    Write-Host "  ll       → eza -lh --git (detailed listing)" -ForegroundColor White
    Write-Host "  cat      → bat (syntax highlighting)" -ForegroundColor White
    Write-Host "  grep     → rg (ripgrep, fast search)" -ForegroundColor White
    Write-Host "  gs       → git status" -ForegroundColor White
    Write-Host "  lazyg    → git add . + commit + push" -ForegroundColor White
    Write-Host "  z <dir>  → zoxide smart cd" -ForegroundColor White
    Write-Host "  ports    → show listening ports" -ForegroundColor White
    Write-Host "  admin    → run command as admin" -ForegroundColor White
    Write-Host "  upgrade  → update all packages" -ForegroundColor White
    Write-Host ""
}

# ─────────────────────────────────────────────
# DEMO 2: CMD + Clink + doskey aliases
# ─────────────────────────────────────────────
Start-DemoPane -Title "PROFILE 2: CMD Enhanced (Clink + doskey)"

if (-not (Test-Path $cmdAliasesPath)) {
    Write-Warning "CMD aliases not found at $cmdAliasesPath"
} else {
    Write-Host "📂 Loading cmd_aliases.cmd..." -ForegroundColor Yellow
    Write-Host ""

    # Show the doskey macros
    Get-Content $cmdAliasesPath | ForEach-Object {
        if ($_ -match 'doskey (\w+)=(.+)') {
            Write-Host "  $($matches[1])".PadRight(12) -ForegroundColor Cyan -NoNewline
            Write-Host "→ $($matches[2])" -ForegroundColor Gray
        }
    }

    Write-Host ""
    Write-Host "Bonus with Clink installed:" -ForegroundColor Green
    Write-Host "  Ctrl+Left/Right  → jump words" -ForegroundColor White
    Write-Host "  Ctrl+Backspace   → delete word" -ForegroundColor White
    Write-Host "  Auto-suggestions → from history" -ForegroundColor White
    Write-Host "  Starship prompt  → same as PowerShell" -ForegroundColor White
}

# ─────────────────────────────────────────────
# DEMO 3: commands demo
# ─────────────────────────────────────────────
Start-DemoPane -Title "LIVE: Running commands from Starship profile"

Write-Host "> ls" -ForegroundColor Yellow
$lsOut = pwsh -NoProfile -Command "
    . '$profilePath'
    eza --icons=always --color=always --group-directories-first '$repoRoot'
" 2>&1 | Out-String
Write-Host $lsOut.Trim()

Write-Host ""
Write-Host "> cat README.md (first 10 lines)" -ForegroundColor Yellow
$catOut = pwsh -NoProfile -Command "
    . '$profilePath'
    Get-Content '$repoRoot\README.md' -TotalCount 10
" 2>&1 | Out-String
Write-Host $catOut.Trim()

Write-Host ""
Write-Host "> gl --oneline -5" -ForegroundColor Yellow
try {
    git -C $repoRoot log --oneline -5 | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
} catch {
    Write-Host "  (not a git repo or no commits)" -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "─────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "  ✅ Demo complete!" -ForegroundColor Green
Write-Host "  To try interactively: restart PowerShell 7" -ForegroundColor White
Write-Host "─────────────────────────────────────────────" -ForegroundColor DarkGray
