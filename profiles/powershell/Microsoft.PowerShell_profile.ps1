### Enhanced PowerShell Profile with Starship Prompt + Unix-like Utilities

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

zoxide init --cmd z powershell | Out-String | Invoke-Expression

Import-Module -Name Terminal-Icons -ErrorAction SilentlyContinue

Invoke-Expression (&starship init powershell) -ErrorAction SilentlyContinue

$commonProfilePath = Join-Path $scriptRoot "common.ps1"
if (Test-Path $commonProfilePath) {
    . $commonProfilePath
} else {
    Write-Host "Warning: Common profile not found at $commonProfilePath" -ForegroundColor Yellow
}

Show-WelcomeMessage

Set-PSReadLineOption -PredictionViewStyle ListView -Colors @{
    Command   = '#87CEEB'
    Parameter = '#98FB98'
    Operator  = '#FFB6C1'
    Variable  = '#DDA0DD'
    String    = '#FFDAB9'
    Number    = '#B0E0E6'
    Type      = '#F0E68C'
    Comment   = '#D3D3D3'
    Keyword   = '#8367c7'
    Error     = '#FF6347'
} -ErrorAction SilentlyContinue

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
Set-PSReadLineKeyHandler -Chord 'Alt+d' -Function DeleteWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
Set-PSReadLineKeyHandler -Chord 'Ctrl+y' -Function Redo

function Update-Profile {
    Invoke-WebRequest -Uri https://github.com/ChrisTitusTech/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $Profile
    Write-Host "Updated PowerShell Profile" -ForegroundColor Green
}

function Find-File ($Name) {
    Get-ChildItem -Recurse -Filter $Name -File | Select-Object -ExpandProperty FullName
}

function Replace-InFile ($File, $Find, $Replace) {
    (Get-Content $File).replace("$Find", $Replace) | Set-Content $file
}

function Get-ProcessByName ($Name) {
    Get-Process -Name $Name -ErrorAction SilentlyContinue
}

function Stop-ProcessByName ($Name) {
    Get-Process -Name $Name -ErrorAction SilentlyContinue | Stop-Process -Force
}

function Kill-Process ($Name) {
    Stop-ProcessByName $Name
}

function Remove-ToRecycleBin ($Path) {
    if (Test-Path $Path -PathType Container) {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($Path,'OnlyErrorDialogs','SendToRecycleBin')
    } else {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($Path,'OnlyErrorDialogs','SendToRecycleBin')
    }
}

function Get-Uptime {
    (Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime | Select-Object Days, Hours, Minutes, Seconds
}

function Invoke-WinUtil {
    Invoke-RestMethod https://christitus.com/win | Invoke-Expression
}

function Invoke-WinUtilDev {
    Invoke-RestMethod https://christitus.com/windev | Invoke-Expression
}

function Commit-AllAndPush {
    git add .
    git commit -m "$args"
}

function Push-AllChanges {
    git add .
    git commit -m "$args"
    git push
}

function Clone-Repository { git clone $args }
function Push-Branch { git push }
function Pull-Branch { git pull }
function Open-Documents { Set-Location -Path ([Environment]::GetFolderPath("MyDocuments")) }

Set-Alias -Name grep -Value Select-String -ErrorAction SilentlyContinue
Set-Alias -Name cat -Value bat -ErrorAction SilentlyContinue

Set-Alias -Name ff -Value Find-File -ErrorAction SilentlyContinue
Set-Alias -Name sed -Value Replace-InFile -ErrorAction SilentlyContinue
Set-Alias -Name pgrep -Value Get-ProcessByName -ErrorAction SilentlyContinue
Set-Alias -Name pkill -Value Stop-ProcessByName -ErrorAction SilentlyContinue
Set-Alias -Name k9 -Value Kill-Process -ErrorAction SilentlyContinue
Set-Alias -Name trash -Value Remove-ToRecycleBin -ErrorAction SilentlyContinue
Set-Alias -Name uptime -Value Get-Uptime -ErrorAction SilentlyContinue
Set-Alias -Name winutil -Value Invoke-WinUtil -ErrorAction SilentlyContinue
Set-Alias -Name winutildev -Value Invoke-WinUtilDev -ErrorAction SilentlyContinue
Set-Alias -Name gcom -Value Commit-AllAndPush -ErrorAction SilentlyContinue
Set-Alias -Name lazyg -Value Push-AllChanges -ErrorAction SilentlyContinue
Set-Alias -Name gcl -Value Clone-Repository -ErrorAction SilentlyContinue
Set-Alias -Name gpush -Value Push-Branch -ErrorAction SilentlyContinue
Set-Alias -Name gpull -Value Pull-Branch -ErrorAction SilentlyContinue
Set-Alias -Name docs -Value Open-Documents -ErrorAction SilentlyContinue
