param (
    [string]$PSRepo = "$env:USERPROFILE\Documents\PowerShell"
)

if (Test-Path $PSRepo) {
    Set-Location $PSRepo
    Write-Output "Changed to $PSRepo"
} else {
    Write-Host "The path $PSRepos does not exist."
}
