<#
.SYNOPSIS
    Get the repository count from the specified repository.
.DESCRIPTION
    This script will alert the user when a change in the number of repositories
    is detected.
.PARAMETER RepoCount
    The current number of repositories.
.PARAMETER PrevCount
    The previous number of repositories.
.EXAMPLE
    PS> .\Get-RepoCount.ps1 -RepoCount 5 -PrevCount 4
    This example will compare the current repository count of 5 with the previous
    repository count of 4.
.NOTES
    File Name      : Get-RepoCount.ps1
    Author         : Jeff Patterson
    Prerequisite   : PowerShell V7
    Date           : 2024-12-03
#>

param (
    [int]$RepoCount,
    [int]$PrevCount
)

# Compare the current repo count with the previous repo count
if ($RepoCount -ne $PrevCount) {
    Write-Host ""
    Write-Host "Repository count changed from $PrevCount to $RepoCount"
}
else {
    Write-Host "Repository count has no changes."
}
