param (
    [string]$Training = "$env:Source\Training"
)

if (Test-Path $Training) {
    Set-Location $Training
    Write-Output "Changed to $Training"
} else {
    Write-Host "The path $Training does not exist."
}


