# This line is used for the CLI Extension oh-my-posh
# that adds useful info and color to the prompt.
# oh-my-posh init pwsh | Invoke-Expression


#Aliases are not case sensitive in Windows.
Set-Alias -Name Repos $env:USERPROFILE\Documents\PowerShell\Get-Repo.ps1 -Option AllScope
Set-Alias -Name Tunnel $env:USERPROFILE\Documents\PowerShell\Get-Tunnel.ps1 -Option AllScope
Set-Alias -Name Startup $env:USERPROFILE\Documents\PowerShell\Get-Startup.ps1 -Option AllScope
Set-Alias -Name PSRepo $env:USERPROFILE\Documents\PowerShell\Get-PSRepo.ps1 -Option AllScope