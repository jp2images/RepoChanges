# This line is used for the CLI Extension oh-my-posh
# that adds useful info and color to the prompt.
# oh-my-posh init pwsh | Invoke-Expression


# Simplify the path to the PowerSehll scripts and make the lines shorter.
$ScriptLocation = Join-Path $env:USERPROFILE "\Documents\PowerShell\"

# Aliases are not case sensitive in Windows.
# These are aliases used to change directories quickly to the most common ones I use.
# Set-Alias -Name Source $env:USERPROFILE\Documents\PowerShell\Get-SourceFolder.ps1 -Option AllScope
Set-Alias -Name Source $ScriptLocation\Get-FolderSource.ps1 -Option AllScope
Set-Alias -Name Training $ScriptLocation\Get-FolderTraining.ps1 -Option AllScope
Set-Alias -Name Repos $ScriptLocation\Get-FolderRepo.ps1 -Option AllScope
Set-Alias -Name Tunnel $ScriptLocation\Get-FolderTunnel.ps1 -Option AllScope
Set-Alias -Name Startup $ScriptLocation\Get-FolderAutoStartup.ps1 -Option AllScope
Set-Alias -Name PSRepo $ScriptLocation\Get-FolderPSRepo.ps1 -Option AllScope

# *****************************************************************************
# Lets do some cool stuff
# *****************************************************************************

# Azure DevOps Repo Changes
Set-Alias -Name Azd $ScriptLocation\Get-RepoChangesAzD.ps1 -Option AllScope
Set-Alias -Name gitLab $ScriptLocation\Get-RepoChangesGitLab.ps1 -Option AllScope
Set-Alias -Name repostatus $ScriptLocation\Get-RepoStatus.ps1 -Option AllScope

# Command Aliases to make it easier to enter CLI commands
# List all files in the current directory including hidden
Set-Alias -Name lsf $ScriptLocation\Get-ChildItem-Force.ps1 -Option AllScope 
