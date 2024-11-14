param (
    [string]$Source = "$env:Source"
)

if (Test-Path $Source) {
    Set-Location $Source
    Write-Output "Changed to $Source"
} else {
    Write-Host "The path $Source does not exist."
}
