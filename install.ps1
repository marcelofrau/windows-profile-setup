#Requires -RunAsAdministrator

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$profileDir = "$env:USERPROFILE\Documents\PowerShell"
$windowsTerminalDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$clinkDir = "$env:LOCALAPPDATA\clink"
$starshipDir = "$env:USERPROFILE\.config"
$ezaDir = "$env:USERPROFILE\.config\eza"
$vscodeDir = "$env:APPDATA\Code\User"

function Write-Banner {
    Clear-Host
    Write-Host @"

    ╔══════════════════════════════════════════════════════╗
    ║       Windows 11 Terminal Profile Installer         ║
    ║    Transform your command line experience         ║
    ╚══════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan
}

function Write-Step {
    param([string]$Title, [string]$Description)
    Write-Host ""
    Write-Host "────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host " $Title" -ForegroundColor Yellow
    Write-Host " $Description" -ForegroundColor Gray
    Write-Host "────────────────────────────────────────────" -ForegroundColor DarkGray
}

function Confirm-Step {
    param([string]$Question)
    Write-Host ""
    Write-Host "❓ $Question" -ForegroundColor White
    $answer = Read-Host "   Proceed? [Y/n]"
    return ($answer -eq '' -or $answer -eq 'y' -or $answer -eq 'Y' -or $answer -eq 'yes')
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✅ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "  ℹ️  $Message" -ForegroundColor Cyan
}

function Write-Skip {
    param([string]$Message)
    Write-Host "  ⏭️  $Message" -ForegroundColor DarkYellow
}

function Write-Warning {
    param([string]$Message)
    Write-Host "  ⚠️  $Message" -ForegroundColor Yellow
}

# ============ WELCOME ============

Write-Banner

Write-Host "This installer will turn your Windows terminal into a" -ForegroundColor White
Write-Host "modern, colorful, Unix-like development environment." -ForegroundColor White
Write-Host ""
Write-Host "Here is what you will get:" -ForegroundColor Green
Write-Host ""
Write-Host "  🚀 Starship     → Beautiful prompt with Git & language info" -ForegroundColor Cyan
Write-Host "  📂 eza          → Modern 'ls' with icons, colors, Git status" -ForegroundColor Cyan
Write-Host "  📄 bat          → 'cat' with syntax highlighting" -ForegroundColor Cyan
Write-Host "  🔍 ripgrep      → Blazing fast file search (rg)" -ForegroundColor Cyan
Write-Host "  🧭 zoxide       → Smart 'cd' that learns your habits" -ForegroundColor Cyan
Write-Host "  🔎 fzf          → Fuzzy finder for everything" -ForegroundColor Cyan
Write-Host "  🖥️  Clink        → Bash-like editing in CMD" -ForegroundColor Cyan
Write-Host "  🎨 Nerd Fonts   → Icon glyphs in your terminal" -ForegroundColor Cyan
Write-Host "  ⚡ PowerShell 7 → Latest cross-platform shell" -ForegroundColor Cyan
Write-Host ""
Write-Host "Everything is optional — you pick what to install." -ForegroundColor White
Write-Host ""

$proceedAll = Confirm-Step "Ready to start? (you can choose each component individually)"

if (-not $proceedAll) {
    Write-Host ""
    Write-Host "No problem! Run me again whenever you want." -ForegroundColor Yellow
    exit 0
}

# ============ SCOOP ============

Write-Step -Title "Step 1: Package Manager" -Description "Scoop installs CLI tools from the command line"

Write-Host "  Scoop is like 'apt-get' for Windows — it installs tools" -ForegroundColor Gray
Write-Host "  to your user folder without admin prompts." -ForegroundColor Gray

$installScoop = Confirm-Step "Install Scoop package manager?"

if ($installScoop) {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "  Installing Scoop..." -ForegroundColor Gray
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod get.scoop.sh | Invoke-Expression
        Write-Success "Scoop installed!"
    } else {
        Write-Success "Scoop already installed"
    }

    scoop update 2>&1 | Out-Null
    scoop install git 2>&1 | Out-Null
    scoop bucket add extras 2>&1 | Out-Null
    scoop bucket add nerd-fonts 2>&1 | Out-Null
    Write-Success "Scoop buckets added (extras, nerd-fonts)"
} else {
    Write-Skip "Scoop installation skipped"
}

# ============ POWER OF SCOOP PACKAGES ============

$scoopInstalled = (Get-Command scoop -ErrorAction SilentlyContinue) -ne $null

if ($scoopInstalled) {
    Write-Step -Title "Step 2: Core CLI Tools" -Description "Modern replacements for classic Unix commands"

    Write-Host ""
    Write-Host "  📂 eza         - Like 'ls', but with icons, colors, and Git integration" -ForegroundColor Cyan
    Write-Host "  🚀 starship    - Customizable prompt showing directory, Git, language version" -ForegroundColor Cyan
    Write-Host "  🔍 ripgrep     - Grep on steroids — searches codebase in milliseconds" -ForegroundColor Cyan
    Write-Host "  📄 bat         - Like 'cat' but with syntax highlighting and line numbers" -ForegroundColor Cyan
    Write-Host "  🧭 zoxide      - 'cd' that learns — 'z proj' jumps to your project folder" -ForegroundColor Cyan
    Write-Host "  🔎 fzf         - Fuzzy search anything — files, history, processes" -ForegroundColor Cyan

    $installTools = Confirm-Step "Install these CLI tools?"

    if ($installTools) {
        $packages = @(
            @{Name='eza'; Desc='Modern ls'},
            @{Name='starship'; Desc='Prompt'},
            @{Name='ripgrep'; Desc='Fast search'},
            @{Name='bat'; Desc='Syntax-highlighted cat'},
            @{Name='zoxide'; Desc='Smart cd'},
            @{Name='fzf'; Desc='Fuzzy finder'}
        )

        foreach ($pkg in $packages) {
            $installed = scoop list $pkg.Name 2>$null
            if (-not $installed) {
                Write-Host "  Installing $($pkg.Name)... ($($pkg.Desc))" -ForegroundColor Gray
                scoop install $pkg.Name 2>&1 | Out-Null
                Write-Success "$($pkg.Name) installed"
            } else {
                Write-Success "$($pkg.Name) already installed"
            }
        }
    } else {
        Write-Skip "CLI tools skipped"
    }
} else {
    Write-Warning "Scoop not installed — skipping CLI tools. Run Scoop installation first."
}

# ============ NERD FONTS ============

Write-Step -Title "Step 3: Nerd Fonts" -Description "Fonts with icon glyphs for your terminal"

Write-Host "  Without a Nerd Font, icons in your prompt and file listings" -ForegroundColor Gray
Write-Host "  will show as empty boxes. These fonts add 8,000+ icons." -ForegroundColor Gray
Write-Host ""
Write-Host "  Recommended: EnvyCodeR Nerd Font + FantasqueSansM Nerd Font" -ForegroundColor Cyan
Write-Host "  (Monospaced programming fonts with all icons built-in)" -ForegroundColor Cyan

$installFonts = Confirm-Step "Install Nerd Fonts? (required for icons)"

if ($installFonts) {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Warning "Scoop required — install Scoop first"
    } else {
        $fonts = @(
            @{Name='EnvyCodeRNerdFont'; Desc='Clean, compact coding font'},
            @{Name='FantasqueSansMNerdFont'; Desc='Sans-serif with ligatures'}
        )

        foreach ($font in $fonts) {
            $installed = scoop list $font.Name 2>$null
            if (-not $installed) {
                Write-Host "  Installing $($font.Name)... ($($font.Desc))" -ForegroundColor Gray
                scoop install $font.Name 2>&1 | Out-Null
                Write-Success "$($font.Name) installed"
            } else {
                Write-Success "$($font.Name) already installed"
            }
        }

        Write-Info "After installing, set your terminal font to e.g. 'EnvyCodeR Nerd Font'"
    }
} else {
    Write-Skip "Nerd Fonts skipped"
}

# ============ POWERSHELL 7 ============

Write-Step -Title "Step 4: PowerShell 7" -Description "Latest cross-platform shell from Microsoft"

Write-Host "  PowerShell 7 is the modern version of PowerShell:" -ForegroundColor Gray
Write-Host "  • Cross-platform (Windows, Mac, Linux)" -ForegroundColor Gray
Write-Host "  • Faster and more compatible" -ForegroundColor Gray
Write-Host "  • Required for PSReadLine v2 and modern modules" -ForegroundColor Gray
Write-Host "  • Comes with predictive IntelliSense" -ForegroundColor Gray

$installPS7 = Confirm-Step "Install PowerShell 7? (recommended)"

if ($installPS7) {
    if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
        Write-Host "  Installing PowerShell 7 via winget..." -ForegroundColor Gray
        winget install --id Microsoft.PowerShell --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
        Write-Success "PowerShell 7 installed!"
    } else {
        Write-Success "PowerShell 7 already installed"
    }
} else {
    Write-Skip "PowerShell 7 skipped (profiles will use Windows PowerShell 5.1)"
}

# ============ CLINK (CMD) ============

Write-Step -Title "Step 5: Clink" -Description "Bring bash-like features to the classic CMD"

Write-Host "  Clink adds to CMD.exe:" -ForegroundColor Gray
Write-Host "  • Ctrl+Left/Right to jump words" -ForegroundColor Gray
Write-Host "  • Ctrl+Backspace to delete words" -ForegroundColor Gray
Write-Host "  • Auto-suggestions from history" -ForegroundColor Gray
Write-Host "  • Starship prompt (same as PowerShell)" -ForegroundColor Gray
Write-Host ""

$installClink = Confirm-Step "Install Clink for CMD enhancement?"

if ($installClink) {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Warning "Scoop required — install Scoop first"
    } else {
        if (-not (Get-Command clink -ErrorAction SilentlyContinue)) {
            Write-Host "  Installing Clink..." -ForegroundColor Gray
            scoop install clink 2>&1 | Out-Null
        } else {
            Write-Success "Clink already installed"
        }

        if (-not (Test-Path $clinkDir)) {
            New-Item -ItemType Directory -Path $clinkDir -Force | Out-Null
        }

        Copy-Item -Path "$repoRoot\dotfiles\clink\starship.lua" -Destination "$clinkDir\starship.lua" -Force
        Write-Success "starship.lua installed for Clink"

        Write-Info "Run 'clink autorun install' from CMD to enable Clink on startup"
    }
} else {
    Write-Skip "Clink skipped"
}

# ============ POWERSHELL MODULES ============

Write-Step -Title "Step 6: PowerShell Modules" -Description "Extra functionality for your profile"

Write-Host "  Terminal-Icons  → Shows file/folder icons in directory listings" -ForegroundColor Cyan
Write-Host "  PSReadLine      → Command-line editing with syntax highlighting" -ForegroundColor Cyan
Write-Host "  (PSReadLine comes with PowerShell 7, just needs update)" -ForegroundColor Gray
Write-Host ""

$installModules = Confirm-Step "Install PowerShell modules?"

if ($installModules) {
    $modules = @(
        @{Name='Terminal-Icons'; Desc='File icons in terminal'}
    )

    foreach ($mod in $modules) {
        if (-not (Get-Module -ListAvailable -Name $mod.Name)) {
            Write-Host "  Installing $($mod.Name)... ($($mod.Desc))" -ForegroundColor Gray
            Install-Module -Name $mod.Name -Scope CurrentUser -Force -SkipPublisherCheck 2>&1 | Out-Null
            Write-Success "$($mod.Name) installed"
        } else {
            Write-Success "$($mod.Name) already installed"
        }
    }
} else {
    Write-Skip "PowerShell modules skipped"
}

# ============ PROFILES ============

Write-Step -Title "Step 7: Profile & Dotfiles" -Description "Your new terminal configuration"

Write-Host "  These files will be installed:" -ForegroundColor White
Write-Host "  • PowerShell profile   → $profileDir" -ForegroundColor Cyan
Write-Host "  • Starship config      → $starshipDir\starship.toml" -ForegroundColor Cyan
Write-Host "  • eza theme            → $ezaDir\theme.yml" -ForegroundColor Cyan
Write-Host "  • CMD aliases          → include-cli in profile" -ForegroundColor Cyan
Write-Host ""
Write-Host "  What the profile gives you:" -ForegroundColor White
Write-Host "  • 'ls' with icons and colors (powered by eza)" -ForegroundColor Gray
Write-Host "  • 'cat' with syntax highlighting (powered by bat)" -ForegroundColor Gray
Write-Host "  • 'grep' → ripgrep, 'ps' → CMD with aliases" -ForegroundColor Gray
Write-Host "  • '..', '...' to go up directories" -ForegroundColor Gray
Write-Host "  • Git shortcuts: gs, ga, gc, gp, gl, lazyg" -ForegroundColor Gray
Write-Host "  • Welcome message with random quote + system info" -ForegroundColor Gray
Write-Host "  • Docker shortcuts: d, dc, k (kubectl)" -ForegroundColor Gray
Write-Host "  • 'admin' / 'please' to run commands as admin" -ForegroundColor Gray
Write-Host "  • 'ports' to see listening ports" -ForegroundColor Gray

$copyProfiles = Confirm-Step "Install profiles and dotfiles?"

if ($copyProfiles) {
    $anyCopied = $false

    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    $sourceDir = "$repoRoot\profiles\powershell"
    Copy-Item -Path "$sourceDir\Microsoft.PowerShell_profile.ps1" -Destination "$profileDir\Microsoft.PowerShell_profile.ps1" -Force
    Copy-Item -Path "$sourceDir\common.ps1" -Destination "$profileDir\common.ps1" -Force
    Copy-Item -Path "$sourceDir\profile.ps1" -Destination "$profileDir\profile.ps1" -Force
    Write-Success "PowerShell profiles copied to $profileDir"
    $anyCopied = $true

    if (-not (Test-Path $starshipDir)) {
        New-Item -ItemType Directory -Path $starshipDir -Force | Out-Null
    }
    Copy-Item -Path "$repoRoot\dotfiles\starship.toml" -Destination "$starshipDir\starship.toml" -Force
    Write-Success "Starship config copied"

    if (-not (Test-Path $ezaDir)) {
        New-Item -ItemType Directory -Path $ezaDir -Force | Out-Null
    }
    Copy-Item -Path "$repoRoot\themes\eza\theme.yml" -Destination "$ezaDir\theme.yml" -Force
    Write-Success "eza theme copied"

    if ($anyCopied) {
        Write-Info "To use the profile now: . `$PROFILE"
        Write-Info "Or restart PowerShell 7"
    }
} else {
    Write-Skip "Profile installation skipped"
}

# ============ WINDOWS TERMINAL ============

Write-Step -Title "Step 8: Windows Terminal Settings" -Description "Optional — apply reference terminal config"

Write-Host "  This copies a pre-configured Windows Terminal settings.json." -ForegroundColor Gray
Write-Host "  It includes profiles for Starship, CMD+Clink, PowerShell 7, and WSL." -ForegroundColor Gray
Write-Host "  Also includes color schemes: Cobalt Neon, Dracula, Gruvbox, Monokai Pro, nord." -ForegroundColor Gray
Write-Host ""
Write-Warning "Your current settings.json will be backed up as settings.backup.json"

$copyTerminal = Confirm-Step "Copy Windows Terminal reference settings?"

if ($copyTerminal) {
    if (Test-Path $windowsTerminalDir) {
        $wtBackup = "$windowsTerminalDir\settings.backup.json"
        if (Test-Path "$windowsTerminalDir\settings.json" -and -not (Test-Path $wtBackup)) {
            Copy-Item -Path "$windowsTerminalDir\settings.json" -Destination $wtBackup -Force
            Write-Success "Current settings backed up to settings.backup.json"
        }
        Copy-Item -Path "$repoRoot\profiles\windows-terminal\settings.json" -Destination "$windowsTerminalDir\settings.json" -Force
        Write-Success "Windows Terminal settings applied!"

        Write-Warning "Review profile paths in Windows Terminal settings.json"
        Write-Info "  Edit icons and commandline paths to match your system"
    } else {
        Write-Warning "Windows Terminal not found — is it installed?"
        Write-Info "  Install from Microsoft Store or: winget install Microsoft.WindowsTerminal"
    }
} else {
    Write-Skip "Windows Terminal settings skipped"
}

# ============ VSCODE ============

Write-Step -Title "Step 9: VSCode Settings" -Description "Optional — editor settings with Nerd Font"

Write-Host "  This copies VSCode settings with:" -ForegroundColor Gray
Write-Host "  • FantasqueSansM Nerd Font with ligatures" -ForegroundColor Gray
Write-Host "  • Block cursor with smooth animation" -ForegroundColor Gray
Write-Host "  • Monokai Pro theme (icon pack + color theme)" -ForegroundColor Gray
Write-Host "  • Telemetry disabled, manual updates" -ForegroundColor Gray
Write-Host "  • Integrated terminal inherits your PowerShell profile" -ForegroundColor Gray
Write-Host ""
Write-Warning "Your current settings.json will be backed up as settings.backup.json"

$copyVSCode = Confirm-Step "Copy VSCode settings?"

if ($copyVSCode) {
    if (Test-Path $vscodeDir) {
        $vscBackup = "$vscodeDir\settings.backup.json"
        if (Test-Path "$vscodeDir\settings.json" -and -not (Test-Path $vscBackup)) {
            Copy-Item -Path "$vscodeDir\settings.json" -Destination $vscBackup -Force
            Write-Success "Current VSCode settings backed up"
        }
        Copy-Item -Path "$repoRoot\profiles\vscode\settings.json" -Destination "$vscodeDir\settings.json" -Force
        Write-Success "VSCode settings applied!"
    } else {
        Write-Warning "VSCode not found — is it installed?"
    }
} else {
    Write-Skip "VSCode settings skipped"
}

# ============ SUMMARY ============

Write-Banner

Write-Host "  🎉 Installation Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "  Here is your new terminal setup:" -ForegroundColor White
Write-Host ""

if ($installScoop) { Write-Host "  ✅ Scoop" -ForegroundColor Green } else { Write-Host "  ⬜ Scoop" -ForegroundColor DarkGray }
if ($installTools) { Write-Host "  ✅ CLI tools (eza, starship, rg, bat, zoxide, fzf)" -ForegroundColor Green } else { Write-Host "  ⬜ CLI tools" -ForegroundColor DarkGray }
if ($installFonts) { Write-Host "  ✅ Nerd Fonts" -ForegroundColor Green } else { Write-Host "  ⬜ Nerd Fonts" -ForegroundColor DarkGray }
if ($installPS7) { Write-Host "  ✅ PowerShell 7" -ForegroundColor Green } else { Write-Host "  ⬜ PowerShell 7" -ForegroundColor DarkGray }
if ($installClink) { Write-Host "  ✅ Clink + Starship for CMD" -ForegroundColor Green } else { Write-Host "  ⬜ Clink" -ForegroundColor DarkGray }
if ($installModules) { Write-Host "  ✅ Terminal-Icons module" -ForegroundColor Green } else { Write-Host "  ⬜ Terminal-Icons module" -ForegroundColor DarkGray }
if ($copyProfiles) { Write-Host "  ✅ PowerShell profiles" -ForegroundColor Green } else { Write-Host "  ⬜ PowerShell profiles" -ForegroundColor DarkGray }
if ($copyTerminal) { Write-Host "  ✅ Windows Terminal settings" -ForegroundColor Green } else { Write-Host "  ⬜ Windows Terminal settings" -ForegroundColor DarkGray }
if ($copyVSCode) { Write-Host "  ✅ VSCode settings" -ForegroundColor Green } else { Write-Host "  ⬜ VSCode settings" -ForegroundColor DarkGray }

Write-Host ""
Write-Host "────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "  NEXT STEPS" -ForegroundColor Yellow
Write-Host "────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

if ($installClink) {
    Write-Host "  1. From CMD, run:      clink autorun install" -ForegroundColor White
    Write-Host "     (enables Clink for all CMD sessions)" -ForegroundColor Gray
}

if ($copyProfiles) {
    Write-Host "  2. Restart PowerShell, or reload now:" -ForegroundColor White
    Write-Host "     . `$PROFILE" -ForegroundColor Gray
}

if ($installFonts -or (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "  3. Set terminal font to 'EnvyCodeR Nerd Font' or similar" -ForegroundColor White
    Write-Host "     (Windows Terminal settings → profiles → font.face)" -ForegroundColor Gray
}

Write-Host "  4. Open a new terminal tab and enjoy your new setup! 🚀" -ForegroundColor White
Write-Host ""
Write-Host "  Documentation and help: https://github.com/marcelofrau/windows-profile-setup" -ForegroundColor Cyan
Write-Host ""
