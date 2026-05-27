# Windows Profile Setup

> A complete terminal setup for Windows 11 — Starship prompt, eza, bat, ripgrep, Clink, and more.

## Overview

This repository contains my personal Windows development environment configuration. It transforms the Windows terminal experience with:

- **Starship prompt** — minimal, fast, customizable prompt with Git and language detection
- **eza** — modern `ls` replacement with icons, colors, and Git integration
- **bat** — `cat` with syntax highlighting and Git gutter
- **ripgrep (rg)** — ultra-fast recursive search
- **zoxide** — smarter `cd` that learns your navigation habits
- **Clink** — bash-like line editing and auto-suggestions for CMD
- **PowerShell 7** profile with Unix-like aliases and utilities

## Preview

Here is what each terminal profile looks like in action:

### 1. Starship Profile (PowerShell 7)

```
     _                 _     _
 ___| |_ __ _ _ __ ___| |__ (_)_ __
/ __| __/ _` | '__/ __| '_ \| | '_ \
\__ \ || (_| | |  \__ \ | | | | |_) |
|___/\__\__,_|_|  |___/_| |_|_| .__/
                              |_|

→ Time is not the enemy | Chrono Trigger
  — Chrono Trigger

──────────────────────────────────
User: marcelo
Host: YODA
OS: Microsoft Windows NT 10.0.26200.0
PowerShell: v7
──────────────────────────────────

[os]─[user]─[dir]─[git]─[lang]─[time]────────────────────
> ls
  assets/    install.ps1    LICENSE    README.md
  dotfiles/  profiles/      themes/

> ll
  drwx---  assets/      27 May 20:56 --
  drwx---  dotfiles/    27 May 20:57 --
  drwx---  profiles/    27 May 20:53 --
  -rwx---  install.ps1 27 May 21:00 --  21k
  -rwx---  LICENSE      27 May 20:56 -- 1.1k
  -rwx---  README.md    27 May 20:58 --  10k
  drwx---  themes/      27 May 20:53 --

> gl --oneline -3
  ebd4436 Interactive installer with guided prompts
  98798d7 Initial commit: Windows terminal profile setup

> gs
  On branch master
  Your branch is up to date with 'origin/master'
  nothing to commit, working tree clean

> cat README.md | head -3
  # Windows Profile Setup
  > A complete terminal setup for Windows 11
  — Starship prompt, eza, bat, ripgrep, Clink, and more.

> which pwsh
  C:\Program Files\PowerShell\7\pwsh.exe
```

### 2. CMD Profile (Clink + doskey aliases)

```
> cmd.exe /k cmd_aliases.cmd

> ls
.gitignore   assets       dotfiles     install.ps1
LICENSE      profiles     README.md    themes

> ll
 Volume in drive C has no label
 Directory of C:\Users\user\windows-profile-setup

27/05/2026  20:56    <DIR>          assets
27/05/2026  20:57    <DIR>          dotfiles
27/05/2026  21:00            21,000 install.ps1
27/05/2026  20:56             1,100 LICENSE
27/05/2026  20:58            10,000 README.md
27/05/2026  20:53    <DIR>          profiles
27/05/2026  20:53    <DIR>          themes

> cat README.md | head -3
  # Windows Profile Setup
  > A complete terminal setup for Windows 11

> clear

> ps
  # Opens PowerShell 7 with Starship profile
```

### 3. ChrisTitus PowerShell Profile

```
> pwsh.exe -NoExit -Command "& '...Microsoft.PowerShell_profile.christitus.ps1'"

     _                 _     _
 ___| |_ __ _ _ __ ___| |__ (_)_ __
/ __| __/ _` | '__/ __| '_ \| | '_ \
\__ \ || (_| | |  \__ \ | | | | |_) |
|___/\__\__,_|_|  |___/_| |_|_| .__/
                              |_|

→ Not all those who wander are lost | J.R.R. Tolkien

──────────────────────────────────
User: marcelo
Host: YODA
OS: Microsoft Windows NT 10.0.26200.0
PowerShell: v7
──────────────────────────────────

> repo
  # Navigates to repo root (ChrisTitus utility)

> winutil
  # Opens Chris Titus Windows Utility
```

## Features

- **Single-command install** — run `install.ps1` and everything is set up
- **Portable profiles** — files use relative paths, work on any Windows 11 machine
- **Idempotent** — safe to re-run the installer anytime
- **Backup-safe** — existing settings are backed up before overwriting
- **Customizable** — each component is a separate file, easy to modify

## Prerequisites

- Windows 11 (may work on Windows 10 with PowerShell 7)
- Admin rights (for package installation)

## Quick Install

Clone the repository and run the installer as Administrator:

```powershell
# Clone to your user folder
git clone https://github.com/marcelofrau/windows-profile-setup.git "$env:USERPROFILE\windows-profile-setup"

# Run installer (as Administrator)
cd "$env:USERPROFILE\windows-profile-setup"
.\install.ps1
```

### Installer Options

| Flag | Description |
|------|-------------|
| `-NoFonts` | Skip Nerd Font installation |
| `-NoTerminal` | Skip Windows Terminal settings |
| `-NoVSCode` | Skip VSCode settings |
| `-NoClink` | Skip Clink setup |
| `-Help` | Show help |

## Manual Installation

### 1. Package Manager: Scoop

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod get.scoop.sh | Invoke-Expression
scoop bucket add extras
scoop bucket add nerd-fonts
```

### 2. Core Packages

```powershell
# CLIs
scoop install eza starship ripgrep bat zoxide fzf

# Nerd Fonts (for icons in terminal)
scoop install EnvyCodeRNerdFont FantasqueSansMNerdFont
```

### 3. PowerShell 7

```powershell
winget install --id Microsoft.PowerShell
```

### 4. PowerShell Modules

```powershell
Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
```

### 5. PowerShell Profile

Copy the profile files to your PowerShell profile directory:

```powershell
$profileDir = "$env:USERPROFILE\Documents\PowerShell"

Copy-Item "profiles\powershell\Microsoft.PowerShell_profile.ps1" "$profileDir\"
Copy-Item "profiles\powershell\common.ps1" "$profileDir\"
Copy-Item "profiles\powershell\profile.ps1" "$profileDir\"
```

### 6. Starship Prompt

```powershell
Copy-Item "dotfiles\starship.toml" "$env:USERPROFILE\.config\starship.toml"
```

### 7. eza Theme

```powershell
Copy-Item "themes\eza\theme.yml" "$env:USERPROFILE\.config\eza\theme.yml"
```

### 8. Clink (for CMD users)

```powershell
scoop install clink
Copy-Item "dotfiles\clink\starship.lua" "$env:LOCALAPPDATA\clink\starship.lua"
# Then from CMD: clink autorun install
```

## Package Table

| Package | Purpose | Manager |
|---------|---------|---------|
| `eza` | Modern `ls` with icons & Git | scoop |
| `starship` | Cross-shell prompt | scoop |
| `bat` | `cat` with syntax highlighting | scoop |
| `ripgrep` | Ultra-fast grep | scoop |
| `zoxide` | Smart directory jumper | scoop |
| `fzf` | Fuzzy finder | scoop |
| `Terminal-Icons` | File/folder icons in PowerShell | PSGallery |
| `PSReadLine` | Improved command-line editing (comes with PS7) | PSGallery |
| `clink` | Bash-like line editing for CMD | scoop |
| Nerd Fonts | Icon glyphs in terminal | scoop (nerd-fonts) |

## File Structure

```
windows-profile-setup/
├── install.ps1                          # Automated setup script
├── profiles/
│   ├── powershell/
│   │   ├── Microsoft.PowerShell_profile.ps1   # Main profile (Starship)
│   │   ├── common.ps1                         # Shared utilities & aliases
│   │   ├── profile.ps1                        # All-hosts functions
│   │   └── cmd_aliases.cmd                    # CMD doskey macros
│   ├── vscode/
│   │   ├── Microsoft.VSCode_profile.ps1      # VSCode integrated terminal profile
│   │   └── settings.json                      # VSCode editor settings
│   └── windows-terminal/
│       └── settings.json                      # Windows Terminal config (reference)
├── dotfiles/
│   ├── starship.toml                          # Starship prompt config
│   └── clink/
│       └── starship.lua                       # Starship for CMD via Clink
├── themes/
│   └── eza/
│       └── theme.yml                          # eza custom color theme
├── assets/
│   ├── motd.txt                               # Welcome banner
│   └── quotes.txt                             # Random startup quotes
├── README.md                                   # This file
└── LICENSE                                    # MIT
```

## Profiles Explained

### `Microsoft.PowerShell_profile.ps1`

The main profile loaded by PowerShell 7. It:
- Initializes zoxide, Terminal-Icons, and Starship
- Loads `common.ps1` from the same directory
- Shows a welcome message with a random quote and system info
- Configures PSReadLine (colors, key bindings, prediction view)
- Provides utilities: `Find-File`, `Replace-InFile`, `Remove-ToRecycleBin`, `Get-Uptime`
- Sets CTT-inspired aliases: `ff`, `sed`, `pgrep`, `pkill`, `winutil`, `lazyg`, etc.

### `common.ps1`

Shared across all profiles. It includes:
- **eza aliases**: `ls`, `ll`, `la`, `lt` (tree view)
- **Navigation**: `cd` with OLDPWD (`cd -`), `mkcd`, `..`, `...`
- **Unix-like commands**: `grep` (rg), `touch`, `rm -rf`, `which`, `less`
- **Git**: `g`, `gs`, `ga`, `gc`, `gco`, `gp`, `gl`
- **System**: `ports`, `killp`, `Get-Uptime`
- **Docker**: `d`, `dc`, `k` (kubectl)
- **Scoop management**: `Update-ScoopAll`, `Install-RecommendedPackages`
- **Signal simulation**: `Send-SIGTERM`, `Send-SIGKILL`, `Send-SIGHUP`

### `profile.ps1`

Additional utilities loaded by the main profile. It provides:
- `admin` / `please` — run commands as admin / repeat last with admin
- `sysinfo` — quick system info
- `ports` — listening ports with process names
- `myip` / `ipinfo` / `localip` — IP address info
- `serve` — quick HTTP server (Python)
- `ytdl` — simplified yt-dlp wrapper
- `extract` — archive extraction by extension
- Git shortcuts: `gs`, `ga`, `gc`, `gp`, `glog`, `ghopen`
- Dev shortcuts: `mci` (mvn clean install), `venv`, `activate`
- `upgrade` — updates all packages (winget + scoop)

## Windows Terminal Setup

A reference `settings.json` is provided in `profiles/windows-terminal/`. It includes:

- **Starship profile** — loads the PowerShell profile with Starship prompt
- **CMD profile** — loads `cmd_aliases.cmd` for Unix-like aliases
- **PowerShell 7 profile** — plain PowerShell 7
- **WSL Ubuntu profile** — if WSL is installed
- **Color schemes**: Cobalt Neon, Flat, Dracula, GruvboxDark, Monokai Pro, nord

To use it, merge the relevant profile entries and color schemes into your own Windows Terminal settings file at:

```
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

> **Important**: The profile paths in the reference use `%USERPROFILE%` — update them to match your setup.

## VSCode Setup

The VSCode profile (`profiles/vscode/Microsoft.VSCode_profile.ps1`) sources the main PowerShell profile so your terminal inside VSCode has the same aliases and prompt.

The editor settings (`profiles/vscode/settings.json`) include:
- Font: FantasqueSansM Nerd Font (with ligatures)
- Block cursor with smooth animation
- Monokai Pro theme
- Telemetry disabled
- Autofetch for Git

## Customization

### Changing the Starship prompt

Edit `dotfiles/starship.toml`. See the [Starship documentation](https://starship.rs/config/) for all options.

### Adding eza theme colors

Edit `themes/eza/theme.yml`. Each file type, permission bit, and Git status can be individually colored.

### Adding your own aliases

Edit `profiles/powershell/common.ps1` to add shared functions and aliases.

### CMD aliases

Edit `profiles/powershell/cmd_aliases.cmd` to add or modify doskey macros.

## Troubleshooting

### "eza: command not found"
Make sure Scoop is in your PATH. Run `scoop install eza`.

### Profile not loading
Check your `$PROFILE` path with: `echo $PROFILE`
The installer places the profile at `$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

### No icons in terminal
- Make sure you have a Nerd Font installed and configured in your terminal
- In Windows Terminal, set `font.face` to a Nerd Font (e.g., `EnvyCodeR Nerd Font`)
- Restart the terminal

### Starship prompt not showing
Run `starship init powershell` manually to check for errors.
Make sure `starship.toml` is at `$env:USERPROFILE\.config\starship.toml`.

### "Clink not installed" when starting CMD
Run `clink autorun install` from a CMD prompt to register Clink as the default handler.

### Windows Terminal profile paths wrong
Edit the `commandline` and `icon` paths in your Windows Terminal settings.json to point to the correct locations on your machine.

## Live Demo

Run the demo script to see all profiles in action with real output:

```
.\demo\demo-script.ps1
```

It opens a guided terminal walkthrough showing the Starship prompt, CMD aliases, ChrisTitus utilities, and running commands like `ls`, `ll`, `cat`, and `gl`.

## Restoring Backups

The installer creates backups before overwriting files:

| File | Backup Location |
|------|----------------|
| Windows Terminal settings | `settings.backup.json` in same folder |
| VSCode settings | `settings.backup.json` in same folder |

To restore, simply copy the `.backup.json` file back to `settings.json`.

## License

MIT — see [LICENSE](LICENSE) for details.

## Credits

- [Chris Titus Tech](https://github.com/ChrisTitusTech/powershell-profile) — PowerShell profile inspiration
- [Starship](https://starship.rs/) — cross-shell prompt
- [eza](https://eza.rocks/) — modern ls replacement
- All open-source package authors
