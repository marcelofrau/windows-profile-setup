# profile.ps1 — Loaded by Microsoft.PowerShell_profile.ps1
# Place this in: (Split-Path $PROFILE)\profile.ps1

$EDITOR_Override = "code"

function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ll  { eza -lh --group-directories-first --icons @args }
    function la  { eza -lAh --group-directories-first --icons @args }
    function l   { eza --icons @args }
    function lt  { eza --tree --icons @args }
    function lta { eza --tree -a --icons @args }
} else {
    function ll  { Get-ChildItem -Force @args | Format-Table -AutoSize }
    function la  { Get-ChildItem -Force -Hidden @args | Format-Table -AutoSize }
    function l   { Get-ChildItem @args }
    function lt  { tree /F @args }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    function cat  { bat --paging=never @args }
    function less { bat --paging=always --plain @args }
}

if (Get-Command rg -ErrorAction SilentlyContinue) {
    function grep { rg @args }
}

function cls    { Clear-Host }
function h      { Get-History }
function j      { Get-Job }
function mkd    { New-Item -ItemType Directory -Path @args -Force }
function touch  {
    param([string]$Path)
    if (Test-Path $Path) { (Get-Item $Path).LastWriteTime = Get-Date }
    else { New-Item -ItemType File -Path $Path | Out-Null }
}

function du {
    param([string]$Path = ".")
    Get-ChildItem $Path | ForEach-Object {
        $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue |
                 Measure-Object -Property Length -Sum).Sum
        [PSCustomObject]@{ Name=$_.Name; Size="{0:N2} MB" -f ($size/1MB) }
    } | Sort-Object { [double]($_.Size -replace ' MB','') } -Descending | Format-Table -AutoSize
}

function df {
    Get-PSDrive -PSProvider FileSystem |
        Select-Object Name,
            @{N='Used(GB)';E={[math]::Round(($_.Used/1GB),2)}},
            @{N='Free(GB)';E={[math]::Round(($_.Free/1GB),2)}},
            @{N='Total(GB)';E={[math]::Round((($_.Used+$_.Free)/1GB),2)}} |
        Format-Table -AutoSize
}

function admin {
    if ($args.Count -gt 0) {
        Start-Process pwsh -Verb RunAs -ArgumentList "-NoExit -Command $args"
    } else {
        Start-Process pwsh -Verb RunAs
    }
}

function please {
    $last = (Get-History -Count 1).CommandLine
    Invoke-Expression "admin $last"
}

function sysinfo { Get-ComputerInfo | Select-Object CsName, OsName, OsVersion, CsProcessors, CsTotalPhysicalMemory }

function ports {
    netstat -ano | Select-String "LISTENING" | ForEach-Object {
        $parts = $_.ToString().Trim() -split '\s+'
        [PSCustomObject]@{
            Proto    = $parts[0]
            Local    = $parts[1]
            PID      = $parts[4]
            Process  = (Get-Process -Id $parts[4] -ErrorAction SilentlyContinue).Name
        }
    } | Format-Table -AutoSize
}

function myip    { (Invoke-RestMethod -Uri "https://ipinfo.io/ip").Trim() }
function ipinfo  { Invoke-RestMethod -Uri "https://ipinfo.io" }
function localip { (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" } | Select-Object -First 1).IPAddress }

function serve {
    param([int]$Port = 8080)
    Write-Host "Serving $(Get-Location) on http://localhost:$Port" -ForegroundColor Cyan
    python -m http.server $Port
}

function tailf {
    param([string]$File, [int]$Lines = 20)
    Get-Content $File -Tail $Lines -Wait
}

function which {
    param([string]$Cmd)
    (Get-Command $Cmd -ErrorAction SilentlyContinue).Source
}

function extract {
    param([string]$File)
    switch -Regex ($File) {
        '\.zip$'        { Expand-Archive $File -DestinationPath . }
        '\.tar\.gz$|\.tgz$' { tar -xzf $File }
        '\.tar\.bz2$'   { tar -xjf $File }
        '\.tar$'        { tar -xf $File }
        '\.7z$'         { 7z x $File }
        default         { Write-Error "Unrecognized format: $File" }
    }
}

function gs   { git status }
function ga   { git add @args }
function gaa  { git add . }
function gc   { git commit -m @args }
function gca  { git commit --amend }
function gp   { git push @args }
function gpo  { git push origin @args }
function gl   { git log --oneline --graph --decorate --all }
function gd   { git diff @args }
function gb   { git branch @args }
function gco  { git checkout @args }
function gst  { git stash @args }
function gsta { git stash apply }
function gcl  { git clone @args }
function gpl  { git pull @args }
function grb  { git rebase @args }
function gtag { git tag @args }

function glog {
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit @args
}

function ghopen {
    $url = git remote get-url origin 2>$null
    if ($url) {
        $url = $url -replace 'git@github\.com:', 'https://github.com/' -replace '\.git$', ''
        Start-Process $url
    }
}

function mci   { mvn clean install @args }
function mcp   { mvn clean package @args }
function mct   { mvn clean test @args }
function mskip { mvn clean install -DskipTests @args }

function venv  { python -m venv .venv }
function activate {
    if (Test-Path ".venv\Scripts\Activate.ps1") { . .venv\Scripts\Activate.ps1 }
    elseif (Test-Path "venv\Scripts\Activate.ps1") { . venv\Scripts\Activate.ps1 }
    else { Write-Warning "No venv found (looked in .venv\ and venv\)" }
}

function pip-upgrade { pip list --outdated --format=columns | Select-Object -Skip 2 | ForEach-Object { pip install -U ($_ -split '\s+')[0] } }

function exp   { explorer . }
function trash {
    param([string]$Path)
    Add-Type -AssemblyName Microsoft.VisualBasic
    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile(
        (Resolve-Path $Path).Path,
        'OnlyErrorDialogs',
        'SendToRecycleBin'
    )
}

function clrclip { Set-Clipboard -Value "" }
function reload { . $PROFILE }

function envs {
    Get-ChildItem Env: | Sort-Object Name | ForEach-Object {
        Write-Host "$($_.Name)" -ForegroundColor Cyan -NoNewline
        Write-Host " = " -NoNewline
        Write-Host "$($_.Value)" -ForegroundColor Yellow
    }
}

function killp {
    param([string]$Name)
    Get-Process -Name $Name -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "Killed: $Name" -ForegroundColor Red
}

function upgrade {
    Write-Host "==> winget upgrade" -ForegroundColor Cyan
    winget upgrade --all --accept-source-agreements --accept-package-agreements
    Write-Host "==> scoop upgrade" -ForegroundColor Cyan
    scoop update *
}

function flush-dns  { ipconfig /flushdns }
function reset-net  { netsh winsock reset; netsh int ip reset }
function ping       { ping.exe -t @args }
function tracert    { tracert.exe @args }

function ytdl {
    if ($args[1]) {
        yt-dlp --no-playlist -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" --merge-output-format mp4 -o "$($args[1]).%(ext)s" $args[0]
    } else {
        yt-dlp --no-playlist -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" --merge-output-format mp4 $args[0]
    }
}
