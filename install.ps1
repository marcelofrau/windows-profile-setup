#Requires -RunAsAdministrator

param(
    [switch]$NoFonts,
    [switch]$NoTerminal,
    [switch]$NoVSCode,
    [switch]$NoClink,
    [switch]$Help
)

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$profileDir = "$env:USERPROFILE\Documents\PowerShell"
$windowsTerminalDir = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$clinkDir = "$env:LOCALAPPDATA\clink"
$starshipDir = "$env:USERPROFILE\.config"
$ezaDir = "$env:USERPROFILE\.config\eza"
$vscodeDir = "$env:APPDATA\Code\User"

if ($Help) {
    Write-Host @"
Windows Profile Setup - Installer
==================================

Usage: .\install.ps1 [options]

Options:
  -NoFonts      Skip Nerd Font installation
  -NoTerminal   Skip Windows Terminal settings copy
  -NoVSCode     Skip VSCode settings copy
  -NoClink      Skip Clink + starship.lua setup
  -Help         Show this help

What this script does:
  1. Installs Scoop (if missing) + required packages
  2. Installs PowerShell 7 via winget
  3. Installs Nerd Fonts via Scoop
  4. Installs Clink + Starship for CMD
  5. Installs PSReadLine + Terminal-Icons modules
  6. Copies PowerShell profiles to $profileDir
  7. Optionally copies Windows Terminal & VSCode settings
  8. Installs eza theme and starship.toml
"@
    exit 0
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows Profile Setup - Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ---- Step 1: Scoop ----
Write-Host "[1/7] Setting up Scoop..." -ForegroundColor Yellow
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing Scoop..." -ForegroundColor Gray
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
} else {
    Write-Host "  Scoop already installed" -ForegroundColor Green
}

scoop update 2>&1 | Out-Null
scoop install git 2>&1 | Out-Null

$buckets = @('extras', 'nerd-fonts')
foreach ($bucket in $buckets) {
    scoop bucket add $bucket 2>&1 | Out-Null
}
Write-Host "  Scoop ready" -ForegroundColor Green

# ---- Step 2: PowerShell 7 ----
Write-Host "[2/7] Installing PowerShell 7..." -ForegroundColor Yellow
if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
    winget install --id Microsoft.PowerShell --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
    Write-Host "  PowerShell 7 installed" -ForegroundColor Green
} else {
    Write-Host "  PowerShell 7 already installed" -ForegroundColor Green
}

# ---- Step 3: Scoop packages ----
Write-Host "[3/7] Installing core packages via Scoop..." -ForegroundColor Yellow
$packages = @(
    'eza',
    'starship',
    'ripgrep',
    'bat',
    'zoxide',
    'fzf'
)

foreach ($pkg in $packages) {
    $installed = scoop list $pkg 2>$null
    if (-not $installed) {
        Write-Host "  Installing $pkg..." -ForegroundColor Gray
        scoop install $pkg 2>&1 | Out-Null
    } else {
        Write-Host "  $pkg already installed" -ForegroundColor Green
    }
}
Write-Host "  Core packages ready" -ForegroundColor Green

# ---- Step 4: Nerd Fonts ----
if (-not $NoFonts) {
    Write-Host "[4/7] Installing Nerd Fonts..." -ForegroundColor Yellow
    $fonts = @('EnvyCodeRNerdFont', 'FantasqueSansMNerdFont')
    foreach ($font in $fonts) {
        $installed = scoop list $font 2>$null
        if (-not $installed) {
            Write-Host "  Installing $font..." -ForegroundColor Gray
            scoop install $font 2>&1 | Out-Null
        } else {
            Write-Host "  $font already installed" -ForegroundColor Green
        }
    }
    Write-Host "  Nerd Fonts ready" -ForegroundColor Green
} else {
    Write-Host "[4/7] Skipping Nerd Fonts (-NoFonts)" -ForegroundColor DarkYellow
}

# ---- Step 5: Clink + Starship ----
if (-not $NoClink) {
    Write-Host "[5/7] Setting up Clink + Starship for CMD..." -ForegroundColor Yellow
    if (-not (Get-Command clink -ErrorAction SilentlyContinue)) {
        scoop install clink 2>&1 | Out-Null
    }

    if (-not (Test-Path $clinkDir)) {
        New-Item -ItemType Directory -Path $clinkDir -Force | Out-Null
    }

    Copy-Item -Path "$repoRoot\dotfiles\clink\starship.lua" -Destination "$clinkDir\starship.lua" -Force
    Write-Host "  Clink starship.lua installed" -ForegroundColor Green

    Write-Host "  NOTE: Run 'clink autorun install' from CMD to enable Clink" -ForegroundColor Yellow
} else {
    Write-Host "[5/7] Skipping Clink setup (-NoClink)" -ForegroundColor DarkYellow
}

# ---- Step 6: PowerShell Modules ----
Write-Host "[6/7] Installing PowerShell modules..." -ForegroundColor Yellow
$modules = @('Terminal-Icons', 'PSReadLine')
foreach ($mod in $modules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Host "  Installing $mod..." -ForegroundColor Gray
        Install-Module -Name $mod -Scope CurrentUser -Force -SkipPublisherCheck 2>&1 | Out-Null
    } else {
        Write-Host "  $mod already installed" -ForegroundColor Green
    }
}
Write-Host "  PowerShell modules ready" -ForegroundColor Green

# ---- Step 7: Profile files ----
Write-Host "[7/7] Installing profile files..." -ForegroundColor Yellow

if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$sourceDir = "$repoRoot\profiles\powershell"
Copy-Item -Path "$sourceDir\Microsoft.PowerShell_profile.ps1" -Destination "$profileDir\Microsoft.PowerShell_profile.ps1" -Force
Copy-Item -Path "$sourceDir\common.ps1" -Destination "$profileDir\common.ps1" -Force
Copy-Item -Path "$sourceDir\profile.ps1" -Destination "$profileDir\profile.ps1" -Force
Write-Host "  PowerShell profiles installed to $profileDir" -ForegroundColor Green

if (-not (Test-Path $starshipDir)) {
    New-Item -ItemType Directory -Path $starshipDir -Force | Out-Null
}
Copy-Item -Path "$repoRoot\dotfiles\starship.toml" -Destination "$starshipDir\starship.toml" -Force
Write-Host "  Starship config installed" -ForegroundColor Green

if (-not (Test-Path $ezaDir)) {
    New-Item -ItemType Directory -Path $ezaDir -Force | Out-Null
}
Copy-Item -Path "$repoRoot\themes\eza\theme.yml" -Destination "$ezaDir\theme.yml" -Force
Write-Host "  Eza theme installed" -ForegroundColor Green

# ---- Optional: Windows Terminal ----
if (-not $NoTerminal) {
    if (Test-Path $windowsTerminalDir) {
        $wtBackup = "$windowsTerminalDir\settings.backup.json"
        if (Test-Path "$windowsTerminalDir\settings.json" -and -not (Test-Path $wtBackup)) {
            Copy-Item -Path "$windowsTerminalDir\settings.json" -Destination $wtBackup -Force
            Write-Host "  Windows Terminal current settings backed up to settings.backup.json" -ForegroundColor Green
        }
        Copy-Item -Path "$repoRoot\profiles\windows-terminal\settings.json" -Destination "$windowsTerminalDir\settings.json" -Force
        Write-Host "  Windows Terminal settings installed (review custom paths)" -ForegroundColor Green
    } else {
        Write-Host "  Windows Terminal not detected, skipping" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "  Skipping Windows Terminal settings (-NoTerminal)" -ForegroundColor DarkYellow
}

# ---- Optional: VSCode ----
if (-not $NoVSCode) {
    if (Test-Path $vscodeDir) {
        $vscBackup = "$vscodeDir\settings.backup.json"
        if (Test-Path "$vscodeDir\settings.json" -and -not (Test-Path $vscBackup)) {
            Copy-Item -Path "$vscodeDir\settings.json" -Destination $vscBackup -Force
            Write-Host "  VSCode current settings backed up to settings.backup.json" -ForegroundColor Green
        }
        Copy-Item -Path "$repoRoot\profiles\vscode\settings.json" -Destination "$vscodeDir\settings.json" -Force
        Write-Host "  VSCode settings installed" -ForegroundColor Green
    } else {
        Write-Host "  VSCode not detected, skipping" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "  Skipping VSCode settings (-NoVSCode)" -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Installation complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Restart PowerShell 7 to load new profile" -ForegroundColor White
Write-Host "  2. If you use CMD, run: clink autorun install" -ForegroundColor White
Write-Host "  3. Review Windows Terminal profiles for correct icon paths" -ForegroundColor White
Write-Host ""
Write-Host "To reload your profile without restarting:" -ForegroundColor Gray
Write-Host "  . `$PROFILE" -ForegroundColor Gray
Write-Host ""
