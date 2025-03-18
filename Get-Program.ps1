param (
    [string]$Repos = "$env:Repos\Tunnel\plc",
    [string]$patFilePath = "$env:USERPROFILE\.ssh\Beckhoff-AzD-pat.txt"
)


if (Test-Path $Repos) {
    Set-Location $Repos
    Write-Output "Changed to $Repos"
} else {
    Write-Host "The path $Repos does not exist."
}
