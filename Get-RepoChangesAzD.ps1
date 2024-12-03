<#
.SYNOPSIS
    Return a list of the changes made to all of the repositories in an Azure 
    DevOps project.
.DESCRIPTION
    This script uses the Azure DevOps REST API to list repositories, branches, 
    and commits for a given organization and project. The script will output 
    the commits for each branch in each repository. The script will also output 
    the number of repositories and branches in the organization and project.
.PARAMETER organization
    The Azure DevOps organization to query. Default is "BeckhoffUS".
.PARAMETER project
    The Azure DevOps project to query. Default is "TunnelWash".
.PARAMETER queryDays
    The number of previous days to query for changes. Default is -1, which 
    will return all changes since yesterday. Must use a negative number.
.PARAMETER patFilePath
    The path to the file containing the Personal Access Token (PAT) for 
    authentication. Default is "$env:USERPROFILE\.ssh\Beckhoff-AzD-pat.txt".
.PARAMETER help -or h
    Display the help message.
.PARAMETER verbose -or v
    Display verbose output.

.EXAMPLE
    PS> .\Get-RepoChangesAzD.ps1 -organization "BeckhoffUS" -project "TunnelWash" -queryDays -3
    This example will query the BeckhoffUS organization and TunnelWash project 
    for changes in the last 3 days.

.NOTES
    File Name      : Get-RepoChangesAzD.ps1
    Author         : Jeff Patterson
    Prerequisite   : PowerShell V7
    Date           : 2024-11-14
#>

param (
    [string]$organization = "BeckhoffUS", # Default organization
    [string]$project = "TunnelWash",
    [int]$queryDays = -1,
    [string]$patFilePath = "$env:USERPROFILE\.ssh\Beckhoff-AzD-pat.txt",
    [switch]$help,
    [switch]$h,
    [switch]$verbose,
    [switch]$v
)

# Display help if -h or --help is specified
if ($h -or $help) {
    Get-Help -Full $MyInvocation.MyCommand.Path
    exit
}

if($v -or $verbose) {
    $showall = $true
    Write-Host "Verbose output is enabled."
}

# Function to save the repo count to a file
function Save-RepoCount {
    param (
        [int]$count
    )
    Set-Content -Path $repoCountFilePath -Value $count
}

# Function to read the repo count from a file
function Get-PreviousRepoCount {
    if (Test-Path -Path $repoCountFilePath) {
        return [int](Get-Content -Path $repoCountFilePath -Raw)
    }
    else {
        return 0
    }
}

# Function to write host with word wrapping
function Write-HostWrapped {
    param (
        [string]$text,
        [int]$maxLength = 80
    )
    $text -split "(.{1,$maxLength})(\s|$)" | ForEach-Object {
        if ($_ -ne '') {
            Write-Host $_
        }
    }
}

# Read the access token (AT) from a file that isn't in the Git Repo. That 
# would be a security problem putting secrets in a repo. PATs should also 
# be per person and never shared so that there is traceability.
$personalAccessToken = Get-Content -Path $patFilePath -Raw

# Define the file path to save the repo count
$repoCountFilePath = "$env:USERPROFILE\repoCountAzD.txt"

# Get the previous repo count
$previousRepoCount = Get-PreviousRepoCount

# Base64 encode the PAT for authentication
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($personalAccessToken)"))

# Define the API URL to list repositories
$uriRepos = "https://dev.azure.com/$organization/$project/_apis/git/repositories?api-version=6.0"

$todaysDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
# Calculate the date for how far to look back for changes
$sinceDate = (Get-Date).AddDays($queryDays).ToString("yyyy-MM-ddTHH:mm:ssZ")

if ($showall) {
    Write-Host ""
    Write-Host "Returning results between the dates: "
    Write-Host "$sinceDate through Today: $todaysDate"
    Write-Host ""
    Write-Host "      To change the date range, use the -queryDays days parameter from the"
    Write-Host "      command line, where days is a negative number indicating the number"
    Write-Host "      of days back to query."
    Write-Host "      E.g., .\Get-RepoChangesAzD.ps1 -queryDays -3"
}

# Make the API request to get repositories
$responseRepos = Invoke-RestMethod -Uri $uriRepos -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) }
$currentRepoCount = $responseRepos.count
# Save the current repo count to the file
Save-RepoCount -count $currentRepoCount

if ($showall) {
    Write-Host ""
    Write-Host "Azure DevOps REPOSITORY Count: $currentRepoCount"
    Write-Host "================================================================================"
}

foreach ($repo in $responseRepos.value) {
    $repoName = $repo.name

    # Define the API URL to list branches
    $uriBranches = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repoName/refs?filter=heads/&api-version=6.0"

    # Make the API request to get branches
    $responseBranches = Invoke-RestMethod -Uri $uriBranches -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) }
    $countBranches = $responseBranches.count
    $pluralbranch = if ($countBranches -ge 2) { "branches" } else { "branch" }

    if ($showall) {
        Write-Host ""
        Write-Host "********************************************************************************"
    }
    Write-Host "Repository: ${repoName} with $countBranches $pluralbranch"
    #   Write-Host "********************************************************************************"

    foreach ($branch in $responseBranches.value) {
        $branchName = $branch.name -replace "refs/heads/", ""

        # Get commits for the branch
        $commitsUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repoName/commits?searchCriteria.itemVersion.version=$branchName&searchCriteria.fromDate=$sinceDate&api-version=6.0"
        $commits = Invoke-RestMethod -Uri $commitsUrl -Method Get -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) }
        $commitCount = $commits.count

        if ($commitCount -ne 0) {
            Write-Host "    COMMITS from $branchName"
            Write-Host "    -----"

            $commits.value | ForEach-Object {
                $commitId = $_.commitId
                $author = $_.author.name
                $authorDate = $_.author.date
                $comment = $_.comment
        
                Write-Host "    Commit ID: $commitId"
                Write-Host "    Author:    $author"
                Write-Host "    Date:      $authorDate"
                Write-Host "    Comment:"
                Write-HostWrapped -text "$comment"
                Write-Host "    -----"
            }    
        }
    }
}

& $env:USERPROFILE\Documents\PowerShell\Get-RepoCount.ps1 -RepoCount $currentRepoCount -PrevCount $previousRepoCount

Write-Host "Azure DevOps check complete."
Write-Host ""
