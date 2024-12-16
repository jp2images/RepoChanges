<#
.SYNOPSIS
    Return a list of the changes made to all of the repositories in a GitLab 
    project.

.DESCRIPTION
    This script uses the GitLab REST API to list repositories, branches, and
    commits for a given project. The script will output the commits for each
    branch in each repository. The script will also output the number of
    repositories and branches in the project.

.PARAMETER days
    The number of previous days to query for changes. Default is 1, which 
    will return all changes since yesterday.

.PARAMETER atFilePath
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
    Date           : 2024-12-09
#>

param (
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
    Write-Host "      To change the date range, use the -days days parameter from the"
    Write-Host "      command line, where days is a negative number indicating the number"
    Write-Host "      of days back to query."
    Write-Host "      E.g., .\Get-RepoChangesGitLab.ps1 -days -3"
}

try {
    # Fetch all projects
    $projects = Invoke-RestMethod -Uri $uriProjects -Method Get -Headers @{ "PRIVATE-TOKEN" = $accessToken }
    $currentRepoCount = $projects.count
    # Save the current repo count to the file
    Save-RepoCount -count $currentRepoCount
     Write-Host "GitLab REPOSITORY Count: $currentRepoCount"
 }
catch {
    Write-Host "Error fetching projects: $_"
    throw
}

$projectNum = 0

foreach ($project in $projects) {
    $projectName = $project.name
    $projectId = $project.id
    $projectNum++

    # Set the GitLab API URL for branches
    $branchesApiUrl = "https://gitlab.com/api/v4/projects/$projectId/repository/branches?private_token=$personalAccessToken"

    try {
        # Get all branches
        $branches = Invoke-RestMethod -Uri $branchesApiUrl -Headers @{ "PRIVATE-TOKEN" = $personalAccessToken }
    }
    catch {
        Write-Host "Error fetching branches: $_"
        throw
    }

    if ($showall) {
        Write-Host "================================================================================"
    }

    $pluralbranch = if ($branches.count -ge 2) { "branches" } else { "branch" }

    Write-Host "Project $($projectNum): $($projectName) (ID: $projectId) $($branches.count) $pluralbranch"

    if ($showall) {
        Write-Host "================================================================================"
    }

    foreach ($branch in $branches) {
        $branchName = $branch.name
        $commitsUrl = "https://gitlab.com/api/v4/projects/$projectId/repository/commits?ref_name=$branchName&since=$sinceDate&until=$untilDate&private_token=$personalAccessToken"
    
        # Make the API request to get the commits
        $response = Invoke-RestMethod -Uri $commitsUrl -Headers @{ "PRIVATE-TOKEN" = $personalAccessToken }
    
        $commitCount = $response.count
        $maxWidth = 70

        if ($commitCount -ne 0) {
            Write-Host ""
            Write-Host "`e[1mCommits from $projectName.$branchName`e[0m"
            Write-Host "    -----"
                
            # Display the commits
            $response | ForEach-Object {  
                $short_id = $_.short_id
                $author = $_.author_name
                $created_at = $_.created_at
                $wrappedString = $_.message
                $message = $wrappedString -replace "`n", ""

                Write-Host "`tID:        $short_id"
                Write-Host "`tAuthor:    $author"
                Write-Host "`tDate:      $created_at"
                Write-Host "`tComment:   $message"
                Write-Host ""
            }
        }
    }
}

Write-Host ""
& $env:USERPROFILE\Documents\PowerShell\Get-RepoCount.ps1 -RepoCount $currentRepoCount -PrevCount $previousRepoCount

Write-Host ""
Write-Host "GitLab check complete. ✔️"
Write-Host ""
