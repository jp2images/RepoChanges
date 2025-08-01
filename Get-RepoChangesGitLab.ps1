<#
.SYNOPSIS
    Return a list of the changes made to all of the repositories in a GitLab 
    project.
.DESCRIPTION
    This script uses the GitLab REST API to list repositories, branches, and
    commits for a given project. The script will output the commits for each
    branch in each repository. The script will also output the number of
    repositories and branches in the project.
.PARAMETER organization
    The GitLab organization to query. Default is "NCS".


.PARAMETER days
    The number of previous days to query for changes. Default is 1, which 
    will return all changes since yesterday.
.PARAMETER patFilePath
    The path to the file containing the Access Token (AT) for authentication. 
    Default is "$env:USERPROFILE\.ssh\NCS-GitLab-at.txt".
.PARAMETER help -or h
    Display the help message.
.PARAMETER verbose -or v
    Display verbose output.

.EXAMPLE
    PS> .\Get-RepoChangesGitLab.ps1 -days 3
    This example will query the GitLab project for changes in the last 3 days.


.NOTES
    File Name      : Get-RepoChangesGitLab.ps1
    Author         : Jeff Patterson
    Prerequisite   : PowerShell V7
    Date           : 2024-12-19
#>

param (
    [string]$organization = "NCS", # Default organization
    # [string]$project = "",
    [int]$days = 3,
    [string]$patFilePath = "$env:USERPROFILE\.ssh\NCS-GitLab-at.txt",
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
$repoCountFilePath = "$env:USERPROFILE\repoCountGitLab.txt"

# Get the previous repo count
$previousRepoCount = Get-PreviousRepoCount




# Set the GitLab API URL for projects
$uriProjects = "https://gitlab.com/api/v4/projects?membership=true&private_token=$personalAccessToken"

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
    Write-Host "`tE.g., .\Get-RepoChangesGitLab.ps1 -days 3"
}

try {
    # Fetch all projects
    $projects = Invoke-RestMethod -Uri $uriProjects -Method Get -Headers @{ "PRIVATE-TOKEN" = $personalAccessToken }
    $currentRepoCount = $projects.count
    # Save the current repo count to the file
    Save-RepoCount -count $currentRepoCount
     Write-Host "GitLab REPOSITORY Count: $currentRepoCount"
 }
catch {
    Write-Host "`e[31mError fetching projects: $_`e[0m"
    throw
}

$projectNum = 0

foreach ($project in $projects) {
    $projectName = $project.name
    $projectId = $project.id
    $projectNum++

    # Set the GitLab API URL for branches
    $uriBranches = "https://gitlab.com/api/v4/projects/$projectId/repository/branches?private_token=$personalAccessToken"

    try {
        # Get all branches
        $branches = Invoke-RestMethod -Uri $uriBranches -Headers @{ "PRIVATE-TOKEN" = $personalAccessToken }
    }
    catch {
        Write-Host "`e[37mError fetching branches: $_`e[0m"
        throw
    }

    $pluralbranch = if ($branches.count -ge 2) { "branches" } else { "branch" }
    Write-Host "Project $($projectNum): $($projectName) (ID: $projectId) $($branches.count) $pluralbranch"

    foreach ($branch in $branches) {
        $branchName = $branch.name
        $commitsUrl = "https://gitlab.com/api/v4/projects/$projectId/repository/commits?ref_name=$branchName&since=$sinceDate&until=$untilDate&private_token=$personalAccessToken"
        # Make the API request to get the commits
        $commits = Invoke-RestMethod -Uri $commitsUrl -Headers @{ "PRIVATE-TOKEN" = $personalAccessToken }
        $commitCount = $commits.count
  
        if ($commitCount -ne 0) {
            Write-Host "`e[93m   From branch: $branchName`e[0m"
                
            # Display the commits
            $commits | ForEach-Object {  
                $short_id = $_.short_id
                $author = $_.author_name
                $created_at = $_.created_at
                $comment = $_.message -replace "`n", ""

                Write-Host "`e[36m`tCommit ID:  $short_id`e[0m"
                Write-Host "`e[36m`tAuthor:`e[0m     `e[94m$author`e[0m"
                Write-Host "`e[36m`tDate:       $created_at`e[0m"
                Write-Host "`e[36m`tComment:    $comment`e[0m"
                
                Write-Host "`t-----"
                Write-Host ""
            }
        }
    }
}

Write-Host ""
& $env:USERPROFILE\Documents\PowerShell\Get-RepoCount.ps1 -RepoCount $currentRepoCount -PrevCount $previousRepoCount
Write-Host ""
Write-Host "`e[1;32mGitLab check complete. ✔️`e[0m"
Write-Host ""
