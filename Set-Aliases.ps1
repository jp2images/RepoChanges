# PowerShell Aliases Configuration
# This script contains all the custom aliases for the PowerShell profile

# Simplify the path to the PowerShell scripts
$ScriptLocation = Join-Path $env:USERPROFILE "\Documents\PowerShell\"

# Display the alias help when the script is loaded
# Show-AliasHelp

# *****************************************************************************
# USER-SPECIFIC ALIASES (JPatterson)
# *****************************************************************************

if($env:USERNAME -eq "JPatterson") {
    Write-Host "`e[1;33mUser Aliases for $env:USERNAME`e[0m"
    Write-Host "These  point to specific folder locations on the local machine."

    # Tunnel Project Navigation
    function Get-FolderConfig { & Set-Location $env:Repos\Tunnel\setup }
    Write-Host "  config   -> Tunnel setup folder" -ForegroundColor DarkGray
    Set-Alias -Name config Get-FolderConfig -Option AllScope
    
    function Get-FolderAlpha { & Set-Location $env:Repos\Tunnel\plc-alpha }
    Write-Host "  alpha    -> Alpha PLC folder" -ForegroundColor DarkGray
    Set-Alias -Name alpha Get-FolderAlpha -Option AllScope
    
    function Get-FolderBeta { & Set-Location $env:Repos\Tunnel\plc-beta }
    Write-Host "  beta     -> Beta PLC folder" -ForegroundColor DarkGray
    Set-Alias -Name beta Get-FolderBeta -Option AllScope
    
    function Get-FolderHmi { & Set-Location $env:Repos\Tunnel\hmi }
    Write-Host "  hmi      -> HMI folder" -ForegroundColor DarkGray
    Set-Alias -Name hmi Get-FolderHmi -Option AllScope

    # Neuron Project Navigation
    function Get-FolderNeuronController { & Set-Location $env:Repos\Tunnel\Neuron\NeuronController }
    Write-Host "  neuronb  -> Neuron Controller Blazor application folder" -ForegroundColor DarkGray
    Set-Alias -Name neuronb Get-FolderNeuronController -Option AllScope
    Write-Host "  nb       -> Neuron Controller Blazor Application folder (short)" -ForegroundColor DarkGray
    Set-Alias -Name nb Get-FolderNeuronController -Option AllScope
    
    function Get-FolderNeuronIO { & Set-Location $env:Repos\Tunnel\Neuron\io-alpha }
    Write-Host "  neuronio -> Neuron IO folder" -ForegroundColor DarkGray
    Set-Alias -Name neuronio Get-FolderNeuronIO -Option AllScope
    Write-Host "  nio      -> Neuron IO folder (short)" -ForegroundColor DarkGray
    Set-Alias -Name nio Get-FolderNeuronIO -Option AllScope

    # Web Development
    Write-Host "  webdev   -> Web development folder" -ForegroundColor DarkGray
    Set-Alias -Name webdev $ScriptLocation\Get-FolderWebDev.ps1 -Option AllScope
    Write-Host "  Source   -> Source folder navigation" -ForegroundColor DarkGray
    Set-Alias -Name Source $ScriptLocation\Get-FolderSource.ps1 -Option AllScope
    Write-Host "  Training -> Training folder navigation" -ForegroundColor DarkGray
    Set-Alias -Name Training $ScriptLocation\Get-FolderTraining.ps1 -Option AllScope
    Write-Host "  Repos    -> Repos folder navigation" -ForegroundColor DarkGray
    Set-Alias -Name Repos $ScriptLocation\Get-FolderRepo.ps1 -Option AllScope
    Write-Host "  Tunnel   -> Tunnel folder navigation" -ForegroundColor DarkGray
    Set-Alias -Name Tunnel $ScriptLocation\Get-FolderTunnel.ps1 -Option AllScope

    # GitHub Aliases
    function Get-gh-create { & gh repo create --private --source=. --remote=origin & git push -u --all & gh browse }
    Write-Host "  ghcreate -> Create private GitHub repo from current dir" -ForegroundColor DarkGray
    Set-Alias -Name ghcreate Get-Gh-Create -Option AllScope
} 
else {
    Write-Host "The user $env:USERNAME does not have aliases assigned."
}


# *****************************************************************************
# COMMON ALIASES (Available for all users)
# *****************************************************************************
Write-Host ""
Write-Host "`e[1;33mGIT Commands that will work for anyone`e[0m"

# Git Shortcut Functions and Aliases
function Get-GitStatus { & git status $args }
Write-Host "  gst      -> git status" -ForegroundColor DarkGray
Set-Alias -Name gst Get-GitStatus -Option AllScope
Write-Host "  status   -> git status" -ForegroundColor DarkGray
Set-Alias -Name status Get-GitStatus -Option AllScope

function Get-GitFetchAll { & git fetch --all }
Write-Host "  gfa      -> git fetch --all" -ForegroundColor DarkGray
Set-Alias -name gfa Get-GitFetchAll -Option AllScope
Write-Host "  fetch    -> git fetch --all" -ForegroundColor DarkGray
Set-Alias -name fetch Get-GitFetchAll -Option AllScope

function Get-GitAddAll { & git add . }
Write-Host "  gaa      -> git add . (all files)" -ForegroundColor DarkGray
Set-Alias -Name gaa Get-GitAddAll -Option AllScope
Write-Host "  addall   -> git add . (all files)" -ForegroundColor DarkGray
Set-Alias -Name addall Get-GitAddAll -Option AllScope

function Get-GitPull { & git pull $args }
Write-Host "  gpl      -> git pull" -ForegroundColor DarkGray
Set-Alias -Name gpl Get-GitPull -Option AllScope
Write-Host "  pull     -> git pull" -ForegroundColor DarkGray
Set-Alias -Name pull Get-GitPull -Option AllScope

function Get-GitPush { & git push $args }
Write-Host "  gps      -> git push" -ForegroundColor DarkGray
Set-Alias -Name gps Get-GitPush -Option AllScope
Write-Host "  push     -> git push" -ForegroundColor DarkGray
Set-Alias -Name push Get-GitPush -Option AllScope


# function Get-GitCommit { & git commit $args }
# Write-Host "  gc       -> git commit -m" ForegroundColor DarkGray
# Set-Alias -Name commit Get-GitCommit -Option AllScope
function Get-GitCommit { 
    param([Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)][string[]]$Message)
    & git commit -m ($Message -join " ")
}
Write-Host "  gc       -> git commit -m \"message\"" -ForegroundColor DarkGray
Set-Alias -Name gc Get-GitCommit -Option AllScope
Write-Host "  commit   -> git commit -m \"message\"" -ForegroundColor DarkGray
Set-Alias -Name commit Get-GitCommit -Option AllScope

function Get-GitSwitch { & git switch $args }
Write-Host "  gsw      -> git switch" -ForegroundColor DarkGray
Set-Alias -Name gsw Get-GitSwitch -Option AllScope
Write-Host "  switch   -> git switch" -ForegroundColor DarkGray
Set-Alias -Name gswitch Get-GitSwitch -Option AllScope

function Get-GitDeleteUnstaged { git checkout . $args }
Write-Host "  undo     -> git checkout . (discard unstaged)" -ForegroundColor DarkGray
Set-Alias -Name undo -Value Get-GitDeleteUnstaged -Option AllScope

function Get-GitforcePush { git push --force-with-lease $args }
Write-Host "  gpf      -> git push --force-with-lease" -ForegroundColor DarkGray
Set-Alias -Name gpf -Value Get-GitforcePush -Option AllScope

# Directory Navigation Aliases
Write-Host "  Startup  -> Startup folder navigation" -ForegroundColor DarkGray
Set-Alias -Name Startup $ScriptLocation\Get-FolderAutoStartup.ps1 -Option AllScope
Write-Host "  PSR      -> PSRepo folder navigation" -ForegroundColor DarkGray
Set-Alias -Name PSR $ScriptLocation\Get-FolderPSRepo.ps1 -Option AllScope

# Repository Management Aliases
# Write-Host "  Azd      -> Azure DevOps repo changes" -ForegroundColor DarkGray
# Set-Alias -Name Azd $ScriptLocation\Get-RepoChangesAzD.ps1 -Option AllScope
Write-Host "  gitLab   -> GitLab repo changes" -ForegroundColor DarkGray
Set-Alias -Name gitLab $ScriptLocation\Get-RepoChangesGitLab.ps1 -Option AllScope
Write-Host "  changes  -> Repository status check" -ForegroundColor DarkGray
Set-Alias -Name changes $ScriptLocation\Get-RepoStatus.ps1 -Option AllScope

# File System Aliases
Write-Host "  lsf      -> List all files including hidden" -ForegroundColor DarkGray
Set-Alias -Name lsf $ScriptLocation\Get-ChildItem-Force.ps1 -Option AllScope

# *****************************************************************************
# ALIAS HELP DISPLAY
# *****************************************************************************

# function Show-AliasHelp {
#     Write-Host "`e[1;36mCommand Aliases for $env:USERNAME`e[0m"
#     Write-Host "`e[1;33mREPOs`e[0m"
#     Write-Host "`e[33mAdd an integer to the command ""changes 3"", to list the commits from the`e[0m"
#     Write-Host "`e[33mprevious 3 days. To see changes from only one repo add the switch -days 2 `e[0m"
#     Write-Host "`e[33mto the command ""gitlab -days 3"" or ommit the switch and number to see`e[0m"
#     Write-Host "`e[33mcommits from the previous 24 hours. ""gitlab""`e[0m"
#     Write-Host "changes : Status of GitLab Engineering Repo"
#     Write-Host ""
#     Write-Host "ghcreate: Create a new GitHub repo and push the current directory to it."
#     Write-Host "          The local folder must alrady have a repo initialized."
#     Write-Host ""
#     Write-Host "`e[1;33mFOLDERS:`e[0m"

# }


