$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$assetsDir = Join-Path $scriptRoot "..\..\assets"

function Show-WelcomeMessage {
    $motdPath = Join-Path $assetsDir "motd.txt"
    if (Test-Path $motdPath) {
        Get-Content $motdPath
    } else {
        Write-Host "Welcome to PowerShell! Type 'Show-Help' for available commands" -ForegroundColor Green
    }
    Write-Host ""
    Show-Quote
    Write-Host ""
    Show-SystemInfo
}

function Show-Quote {
    $quotesPath = Join-Path $assetsDir "quotes.txt"
    if (Test-Path $quotesPath) {
        $quotes = @(Get-Content $quotesPath | Where-Object { $_ -match '\S' })
        if ($quotes.Count -gt 0) {
            $random = Get-Random -Minimum 0 -Maximum $quotes.Count
            $accent = $PSStyle.Foreground.BrightYellow
            $dim = $PSStyle.Foreground.BrightBlack
            $reset = $PSStyle.Reset
            $line = $quotes[$random]
            if ($line -contains '|') {
                $parts = $line -split '\s*\|\s*'
                $quote = $parts[0]
                $reference = $parts[1]
                Write-Host "${accent}→${reset} $quote"
                Write-Host "${dim}  — $reference${reset}"
            } else {
                Write-Host "${accent}→${reset} $line"
            }
        }
    }
}

Set-Alias -Name quote -Value Show-Quote -Force

function Show-SystemInfo {
    $username = $env:USERNAME
    $hostname = $env:COMPUTERNAME
    $osVersion = [System.Environment]::OSVersion.VersionString
    $pwshVersion = $PSVersionTable.PSVersion.Major
    $dim = $PSStyle.Foreground.BrightBlack
    $reset = $PSStyle.Reset
    $accent = $PSStyle.Foreground.BrightCyan
    Write-Host "${dim}──────────────────────────────────${reset}"
    Write-Host "${accent}User${reset}${dim}:${reset} $username"
    Write-Host "${accent}Host${reset}${dim}:${reset} $hostname"
    Write-Host "${accent}OS${reset}${dim}:${reset} $osVersion"
    Write-Host "${accent}PowerShell${reset}${dim}:${reset} v$pwshVersion"
    Write-Host "${dim}──────────────────────────────────${reset}"
}

if (Test-Path Alias:ls) {
    Remove-Item -Path Alias:ls -Force
}

function ls { eza --icons=always --color=always --group-directories-first @args }
function ll { eza --icons=always --color=always --group-directories-first -l -h --git @args }
function l { eza --icons=always --color=always --group-directories-first -l -h --git @args }
function la { eza --icons=always --color=always --group-directories-first -a @args }
function lt { eza --tree --icons=always --color=always --level=2 @args }
function lsn { Get-ChildItem @args }

$ezaConfigDir = Join-Path $scriptRoot "..\..\themes\eza"
if (Test-Path $ezaConfigDir) {
    $env:EZA_CONFIG_DIR = $ezaConfigDir
}

Set-PSReadLineKeyHandler -Key Ctrl+a -Function BeginningOfLine
Set-PSReadLineKeyHandler -Key Ctrl+e -Function EndOfLine
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteChar
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

function grep { rg @args }
function Search-Hidden { rg --hidden --no-ignore @args }

function mkcd {
    param([string]$dir)
    mkdir $dir | Out-Null
    cd $dir
}

function Open-CodeHere { code . }
function Clear-Console { Clear-Host }
function Copy-LocationPath { (Get-Location).Path | Set-Clipboard }

function g { git @args }
function gs { git status }
function ga { git add @args }
function gc { git commit -m $args }
function gco { git checkout @args }
function gp { git push }
function gl { git log --oneline --graph --decorate }

function ports { netstat -ano | findstr LISTENING }
function killp { param($p) Stop-Process -Id $p -Force }

function d { docker @args }
function dc { docker compose @args }
function k { kubectl @args }

function Get-CommandSource { Get-Command @args }
function Get-ProcessList { Get-Process @args }
function Get-TopProcesses { Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 }
function less { more @args }

function Read-FileHead {
    param([int]$n = 10)
    if ($args) {
        Get-Content @args | Select-Object -First $n
    } else {
        $input | Select-Object -First $n
    }
}

function Read-FileTail {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $Args
    )
    if ($Args -contains '-f') {
        Get-Content $Args[-1] -Tail 10 -Wait
    } else {
        $n = 10
        if ($args) {
            Get-Content @args | Select-Object -Last $n
        } else {
            $input | Select-Object -Last $n
        }
    }
}

function Search-Files {
    param([string]$pattern)
    if ($pattern) {
        Get-ChildItem -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -match $pattern }
    } else {
        Get-ChildItem -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Get-ManualPage { Get-Help @args }
function Get-CommandPath { (Get-Command @args).Source }

function Invoke-Tar {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $Args
    )
    $tarExe = Get-Command tar.exe -ErrorAction SilentlyContinue
    if ($tarExe) {
        & $tarExe @Args
    } else {
        Write-Host "tar.exe not found. Please install it or use 7z instead." -ForegroundColor Red
    }
}

function Invoke-Zip {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $Args
    )
    $zipExe = Get-Command zip.exe -ErrorAction SilentlyContinue
    if ($zipExe) {
        & $zipExe @Args
    } else {
        if ($Args.Count -ge 2) {
            $output = $Args[0]
            $items = $Args[1..($Args.Count-1)]
            Compress-Archive -Path $items -DestinationPath $output -Force
        }
    }
}

if (Get-Alias rm -ErrorAction SilentlyContinue) {
    Remove-Item -Path Alias:rm -Force -ErrorAction SilentlyContinue
}

function Remove-Item-Enhanced {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $Args
    )
    $Force = $false
    $Recurse = $false
    $Paths = @()
    foreach ($arg in $Args) {
        if ($arg -eq '-f' -or $arg -eq '-force') {
            $Force = $true
        } elseif ($arg -eq '-r' -or $arg -eq '-recurse') {
            $Recurse = $true
        } elseif ($arg -eq '-fr' -or $arg -eq '-rf') {
            $Force = $true
            $Recurse = $true
        } else {
            $Paths += $arg
        }
    }
    foreach ($path in $Paths) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Force:$Force -Recurse:$Recurse -ErrorAction SilentlyContinue
        }
    }
}

Set-Alias -Name rm -Value Remove-Item-Enhanced -Force

if (Get-Alias cd -ErrorAction SilentlyContinue) {
    Remove-Item -Path Alias:cd -Force -ErrorAction SilentlyContinue
}

$global:OLDPWD = $null

function cd {
    param([string]$Path)
    $currentLocation = (Get-Location).Path
    if ($Path -eq '-') {
        if ($null -eq $global:OLDPWD) {
            Write-Host "OLDPWD not set" -ForegroundColor Yellow
            return
        }
        $Path = $global:OLDPWD
    }
    if ([string]::IsNullOrEmpty($Path)) {
        $Path = $env:USERPROFILE
    }
    $global:OLDPWD = $currentLocation
    Set-Location -Path $Path
}

function touch ($File) {
    if (Test-Path $File) {
        (Get-Item $File).LastWriteTime = Get-Date
    } else {
        New-Item $File -ItemType File | Out-Null
    }
}

function mkdir {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $Paths
    )
    foreach ($path in $Paths) {
        New-Item -ItemType Directory -Path $path -Force -ErrorAction SilentlyContinue | Out-Null
    }
}

function Update-ScoopAll {
    Write-Host "Updating Scoop and all packages..." -ForegroundColor Green
    scoop update scoop
    scoop update *
    Write-Host "Update complete!" -ForegroundColor Green
}

function Install-RecommendedPackages {
    Write-Host "Installing recommended packages..." -ForegroundColor Green
    $packages = @('bottom', 'gh', 'lazygit', 'tldr', 'ncdu', 'dust', 'nmap', 'croc', 'lazydocker', 'hyperfine', 'tokei')
    foreach ($pkg in $packages) {
        Write-Host "  > $pkg" -ForegroundColor Cyan
        scoop install $pkg 2>&1 | Out-Null
    }
    Write-Host "Packages installed successfully!" -ForegroundColor Green
}

Set-Alias -Name grep -Value Select-String -ErrorAction SilentlyContinue
Set-Alias -Name cat -Value bat -ErrorAction SilentlyContinue
Set-Alias -Name unzip -Value Expand-Archive -ErrorAction SilentlyContinue
Set-Alias -Name cp -Value Copy-Item -Force -ErrorAction SilentlyContinue
Set-Alias -Name mv -Value Move-Item -Force -ErrorAction SilentlyContinue
Set-Alias -Name pwd -Value Get-Location -ErrorAction SilentlyContinue
Set-Alias -Name btm -Value bottom -ErrorAction SilentlyContinue
Set-Alias -Name df -Value dust -ErrorAction SilentlyContinue
Set-Alias -Name du -Value ncdu -ErrorAction SilentlyContinue
Set-Alias -Name lzd -Value lazydocker -ErrorAction SilentlyContinue
Set-Alias -Name help2 -Value tldr -ErrorAction SilentlyContinue
Set-Alias -Name lg -Value lazygit -ErrorAction SilentlyContinue

function Reload-Profile {
    Write-Host "Reloading PowerShell profile..." -ForegroundColor Green
    . $PROFILE
    Write-Host "Profile reloaded!" -ForegroundColor Green
}

function Send-Signal {
    param(
        [Parameter(Mandatory=$true)]
        [int]$ProcessId,
        [Parameter(Mandatory=$false)]
        [string]$Signal = "TERM"
    )
    $signals = @{
        "TERM"  = 15
        "KILL"  = 9
        "STOP"  = 19
        "CONT"  = 18
        "HUP"   = 1
    }
    if ($signals.ContainsKey($Signal)) {
        $signalNum = $signals[$Signal]
        Stop-Process -Id $ProcessId -ErrorAction SilentlyContinue
        Write-Host "Sent SIG$Signal (signal $signalNum) to process $ProcessId" -ForegroundColor Yellow
    } else {
        Write-Host "Unknown signal: $Signal" -ForegroundColor Red
        Write-Host "Available signals: $(($signals.Keys | Join-String -Separator ', '))" -ForegroundColor Gray
    }
}

function Send-SIGTERM { param([int]$ProcessId) Send-Signal -ProcessId $ProcessId -Signal "TERM" }
function Send-SIGKILL { param([int]$ProcessId) Send-Signal -ProcessId $ProcessId -Signal "KILL" }
function Send-SIGHUP { param([int]$ProcessId) Send-Signal -ProcessId $ProcessId -Signal "HUP" }

Set-Alias -Name pkill-term -Value Send-SIGTERM -ErrorAction SilentlyContinue
Set-Alias -Name pkill-kill -Value Send-SIGKILL -ErrorAction SilentlyContinue
Set-Alias -Name pkill-hup -Value Send-SIGHUP -ErrorAction SilentlyContinue
