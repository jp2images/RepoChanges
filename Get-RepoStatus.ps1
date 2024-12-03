<#
.SYNOPSIS
    This script checks for changes in all repositories from Azure DevOps and GitLab.
.DESCRIPTION
    The script will output the number of repositories in each system and the number
    of changes in each repository along with the SHA, committer, date, and message.
.PARAMETER h -OR help
    Display the help message.
.PARAMETER verbose -or v
    Display verbose output.
.EXAMPLE
    PS> .\Get-RepoStatus.ps1 -verbose
.EXAMPLE
    PS> .\Get-RepoStatus.ps1 -v
.EXAMPLE
    PS> .\Get-RepoStatus.ps1 -help
.EXAMPLE
    PS> .\Get-RepoStatus.ps1 -h

.NOTES
    File Name      : Get-RepoStatus.ps1
    Author         : Jeff Patterson
    Prerequisite   : PowerShell V7
    Date           : 2024-11-27
#>

param (
    [switch]$help,
    [switch]$h,
    [switch]$verbose,
    [switch]$v
)

if($h -or $help) {
    Get-Help -Full $MyInvocation.MyCommand.Path
    exit
}

if($v -or $verbose) {
    $showall = $true
    Write-Host "Verbose output is enabled."
}

Clear-Host
Write-Host "--------------------------------------------------------------------------------"
Write-Host "Checking the Azure DevOps Repositories using the Alias 'AzD'"
Write-Host "--------------------------------------------------------------------------------"
if ($showall) {
    AzD -verbose
} else {
    AzD
}

Write-Host "--------------------------------------------------------------------------------"
Write-Host "Checking the GitLab Repositories using the Alias 'gitlab'"
Write-Host "--------------------------------------------------------------------------------"
if($showall) {
    gitlab -verbose
} else {
    gitlab
}

Write-Host "--------------------------------------------------------------------------------"
Write-Host "Checking is complete."
Write-Host "--------------------------------------------------------------------------------"
Write-Host ""
Write-Host ""

