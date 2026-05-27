$mainProfile = Join-Path (Split-Path $PROFILE) "Microsoft.PowerShell_profile.ps1"
if (Test-Path $mainProfile) {
    . $mainProfile
}
