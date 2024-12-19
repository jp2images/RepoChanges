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
.PARAMETER days
    The number of previous days to query for changes. Must use a negative number. 
    Default is 1, which will return all changes since yesterday. 
.PARAMETER patFilePath
    The path to the file containing the Personal Access Token (PAT) for 
    authentication. Default is "$env:USERPROFILE\.ssh\Beckhoff-AzD-pat.txt".
.PARAMETER help -or h
    Display the help message.
.PARAMETER verbose -or v
    Display verbose output.

.EXAMPLE
    PS> .\Get-RepoChangesAzD.ps1 -organization "BeckhoffUS" -project "TunnelWash" -days 3
    This example will query the BeckhoffUS organization and TunnelWash project 
    for changes in the last 3 days.

.NOTES
    File Name      : Get-RepoChangesAzD.ps1
    Author         : Jeff Patterson
    Prerequisite   : PowerShell V7
    Date           : 2024-12-19
#>

param (
    [string]$organization = "BeckhoffUS", # Default organization
    [string]$project = "TunnelWash",
    [int]$days = 1,
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

if($days -le 0) {
    Write-Host "The number of days must be a positive number."
    exit
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

# Set the Azure DevOps API URL for repositories
$uriRepos = "https://dev.azure.com/$organization/$project/_apis/git/repositories?api-version=6.0"

$untilDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
# Calculate the date for how far to look back for changes
$sinceDate = (Get-Date).AddDays($days * -1).ToString("yyyy-MM-ddTHH:mm:ssZ")

if ($showall) {
    Write-Host ""
    Write-Host "Returning results between the dates: "
    Write-Host "$sinceDate through Today: $untilDate"
    Write-Host ""
    Write-Host "`tTo change the date range, use the -days days parameter from the"
    Write-Host "`tcommand line, where days is a positive number indicating the number"
    Write-Host "`tof days back to query."
    Write-Host "`tE.g., .\Get-RepoChangesAzD.ps1 -days 3"
}

try{
    # Make the API request to get repositories
    $responseRepos = Invoke-RestMethod -Uri $uriRepos -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) }
    $currentRepoCount = $responseRepos.count
    # Save the current repo count to the file
    Save-RepoCount -count $currentRepoCount
    Write-Host "Azure DevOps REPOSITORY Count: $currentRepoCount"
}
catch {
    Write-Host "Error fetching repos: $_"
    throw
}

$repoNum = 0

foreach ($repo in $responseRepos.value) {
    $repoName = $repo.name

    $repoNum++

    # Define the API URL to list branches
    $uriBranches = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repoName/refs?filter=heads/&api-version=6.0"

    try {
    # Make the API request to get branches
    $branches = Invoke-RestMethod -Uri $uriBranches -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) }
    }
    catch {
        Write-Host "Error fetching branches: $_"
        throw
    }

    if ($showall) {
        Write-Host "================================================================================"
    }

    $pluralbranch = if ($branches.count -ge 2) { "branches" } else { "branch" }
    Write-Host "Repository ${repoNum}: ${repoName} with $($branches.count) $pluralbranch"
    if ($showall) {
        Write-Host "================================================================================"
    }

    foreach ($branch in $branches.value) {
        $branchName = $branch.name -replace "refs/heads/", ""
        $commitsUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repoName/commits?searchCriteria.itemVersion.version=$branchName&searchCriteria.fromDate=$sinceDate&api-version=6.0"
        # Make the API request to get the commits
        $commits = Invoke-RestMethod -Uri $commitsUrl -Method Get -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) }
        $commitCount = $commits.count

        if ($commitCount -ne 0) {
            Write-Host ""
            Write-Host "`e[1mCommits from $branchName`e[0m"
            Write-Host "`t-----"

            # Display the commits
            $commits.value | ForEach-Object {
                $commitId = $_.commitId
                $author = $_.author.name
                $authorDate = $_.author.date
                $comment = $_.comment
        
                Write-Host "`tCommit ID: $commitId"
                Write-Host "`tAuthor:    $author"
                Write-Host "`tDate:      $authorDate"
                Write-Host "`tComment:"
                Write-HostWrapped -text "$comment"
                Write-Host "`t-----"
            }    
        }
    }
}

Write-Host ""
& $env:USERPROFILE\Documents\PowerShell\Get-RepoCount.ps1 -RepoCount $currentRepoCount -PrevCount $previousRepoCount
Write-Host ""
Write-Host "Azure DevOps check complete. ✔️"
Write-Host ""
