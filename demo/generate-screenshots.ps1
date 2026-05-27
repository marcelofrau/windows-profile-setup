# Generate terminal screenshots using silicon
$demoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $demoDir
$profilePath = "$env:USERPROFILE\scripts\profiles\work\windows\Microsoft.PowerShell_profile.ps1"

function Out-Screenshot {
    param([string]$Title, [string]$Command, [string]$FilePrefix)
    Write-Host "Generating $FilePrefix..." -ForegroundColor Yellow

    $ansi = pwsh -NoLogo -NoProfile -Command "
        `$Host.UI.RawUI.ForegroundColor = [ConsoleColor]::White
        Write-Host ''

        # Run the command and capture output with ANSI
        Invoke-Expression -Command '$Command' 2>&1 | ForEach-Object {
            if (`$_ -is [System.Management.Automation.ErrorRecord]) {
                Write-Host `"  ERROR: `$(`$_.Exception.Message)`" -ForegroundColor Red
            } else {
                `$_
            }
        }
    " 2>&1 | Out-String

    $ansi | silicon `
        --background '#1E1F28' `
        --font 'Cascadia Code' `
        --theme Dracula `
        --pad 20 `
        --shadow ` `
        --output "$demoDir\$FilePrefix.png"

    Write-Host "  -> $demoDir\$FilePrefix.png" -ForegroundColor Green
}

# Screenshot 1: Starship welcome + ls
Write-Host "=== Starship Profile ===" -ForegroundColor Cyan
Out-Screenshot `
    -Title "Starship Welcome" `
    -Command "pwsh -NoLogo -NoExit -Command `"& '$profilePath'`"" `
    -FilePrefix "starship-welcome"

Write-Host "Done!" -ForegroundColor Green
