# Snippet to test for the current user
if ($env:USERNAME -eq "JPatterson") { }

# Test if an extension is installed and if not install it.
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    # This line is used for the CLI Extension oh-my-posh
    # that adds useful info and color to the prompt.
    oh-my-posh init pwsh | Invoke-Expression
}
else {
    Write-Host "oh-my-posh not initialized."
}

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
Set-Alias -Name changes $ScriptLocation\Get-RepoStatus.ps1 -Option AllScope

# Command Aliases to make it easier to enter CLI commands
# List all files in the current directory including hidden
Set-Alias -Name lsf $ScriptLocation\Get-ChildItem-Force.ps1 -Option AllScope 


# If there is a user on the calling machine that matches the string, then
# create the aliases for that user.
if($env:USERNAME -eq "JPatterson") {
    Set-Alias -Name webdev $ScriptLocation\Get-Folder-WebDev.ps1 -Option AllScope

    # Git Shortcut Aliases
    function Get-GitStatus { & git status $args}
    Set-Alias -Name status Get-GitStatus -Option AllScope

    function Get-GitFetchAll { & git fetch --all}
    Set-Alias -name fetch Get-GitFetchAll -Option AllScope

    function Get-GitAddAll { & git add .}
    Set-Alias -Name addall Get-GitAddAll -Option AllScope

    function Get-GitPull { & git pull $args}
    Set-Alias -Name pull Get-GitPull -Option AllScope

    function Get-GitPush { & git push $args}
    Set-Alias -Name push Get-GitPush -Option AllScope

    function Get-GitCommit { & git commit $args}
    Set-Alias -name commit Get-GitCommit -Option AllScope

    function Get-GitSwitch { & git switch $args}
    Set-Alias -name gswitch Get-GitSwitch -Option AllScope

    function Get-FolderPLC { & Set-Location $env:Repos\Tunnel\PLC}
    Set-Alias -Name plc Get-FolderPLC -Option AllScope
    
    function Get-FolderConfig { & Set-Location $env:Repos\Tunnel\setup}
    Set-Alias -Name config Get-FolderConfig -Option AllScope

    # GitHub aliases
    function Get-gh-create { & gh repo create --private --source=. --remote=origin & git push -u --all & gh browse }
    Set-Alias -Name ghcreate Get-Gh-Create -Option AllScope
} 
else {
    Write-Host "The user $env:USERNAME does not have that alias."
}

Write-Host ""
Write-Host "`e[1;33mGit Command Aliases`e[0m"
Write-Host "status  : git status."
Write-Host "gswitch : git switch."
Write-Host "fetch   : git fetch --all."
Write-Host "pull    : git pull."
Write-Host "addall  : git add ."
Write-Host "commit  : git commit."
Write-Host "push    : git push."
Write-Host "ghcreate: Create a new GitHub repo and push the current directory to it."
Write-Host ""
Write-Host "`e[1;33mREPO Updates`e[0m"
Write-Host "`e[33mAdd integer: changes 3 to look back 3 days Fri-Sun`e[0m"
Write-Host "changes : All Repo Status'."
Write-Host "Azd     : Get the Azure DevOps Repo Changes."
Write-Host "gitLab  : Get the GitLab Repo Changes."
Write-Host ""
Write-Host "lsf     : List all files in the current directory including hidden."
Write-Host ""
Write-Host "`e[1;33mFolder changing aliases.`e[0m"
Write-Host "Source  : Source folder."
Write-Host "Repos   : Repos folder."
Write-Host "Startup : Startup folder."
Write-Host "PSRepo  : PSRepo folder."
Write-Host "Training: Training folder."
Write-Host "webdev  : WebDev training folder."
Write-Host "tunnel  : Tunnel folder."
Write-Host "plc     : Tunnel Controller PLC Repo folder."
Write-Host "config  : Tunnel Controller Setup Repo folder."
Write-Host ""
# *****************************************************************************