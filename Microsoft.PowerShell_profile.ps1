oh-my-posh init pwsh | Invoke-Expression
Set-Alias -Name repos $env:USERPROFILE\Documents\PowerShell\Get-Repo.ps1 -Option AllScope
Set-Alias -Name tunnel $env:USERPROFILE\Documents\PowerShell\Get-Tunnel.ps1 -Option AllScope
Set-Alias -Name startup $env:USERPROFILE\Documents\PowerShell\Get-Startup.ps1 -Option AllScope
Set-Alias -Name PSRepo $env:USERPROFILE\Documents\PowerShell\Get-PSRepo.ps1 -Option AllScope