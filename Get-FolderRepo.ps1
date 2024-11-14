param (
    [string]$Repos = "$env:Repos\"
)

if (Test-Path $Repos) {
    Set-Location $Repos
    Write-Output "Changed to $Repos"
} else {
    Write-Host "The path $Repos does not exist."
}
