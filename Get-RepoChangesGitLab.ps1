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


## Pagination for projects
$allProjects = @()
$page = 1
$perPage = 100
$hasMoreProjects = $true

# The date range for the query starting with today.
$untilDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
# Calculate the date for how far to look back for changes.
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
    while ($hasMoreProjects) {
        $uriProjects = "https://gitlab.com/api/v4/projects?membership=true&per_page=$perPage&page=$page&private_token=$personalAccessToken"
        $projectsPage = Invoke-RestMethod -Uri $uriProjects -Method Get -Headers @{ "PRIVATE-TOKEN" = $personalAccessToken }
        if ($projectsPage -is [array]) {
            if ($projectsPage.Length -gt 0) {
                $allProjects += $projectsPage
                $page++
            } else {
                $hasMoreProjects = $false
            }
        } elseif ($projectsPage) {
            $allProjects += $projectsPage
            $hasMoreProjects = $false
        } else {
            $hasMoreProjects = $false
        }
    }
    $currentRepoCount = $allProjects.Length
    Save-RepoCount -count $currentRepoCount
    Write-Host "GitLab REPOSITORY Count: $currentRepoCount"
}
catch {
    Write-Host "`e[31mError fetching projects: $_`e[0m"
    throw
}

$projectNum = 0



# Add index to each project before parallelization using PSCustomObject
$indexedProjects = @()
for ($i = 0; $i -lt $allProjects.Length; $i++) {
    $proj = $allProjects[$i]
    $indexedProjects += [PSCustomObject]@{
        name = $proj.name
        id = $proj.id
        ProjectIndex = $i + 1
        TotalProjects = $allProjects.Length
    }
}

# Parallelize projects (outer loop) with index
$indexedProjects | ForEach-Object -Parallel {
    $projectName = $_.name
    $projectId = $_.id
    $perPage = 100
    $sinceDate = $using:sinceDate
    $untilDate = $using:untilDate
    $personalAccessToken = $using:personalAccessToken
    $projectIndex = $_.ProjectIndex
    $totalProjects = $_.TotalProjects

    # Pagination for branches
    $allBranches = @()
    $branchPage = 1
    $hasMoreBranches = $true
    while ($hasMoreBranches) {
        $uriBranches = "https://gitlab.com/api/v4/projects/$projectId/repository/branches?per_page=$perPage&page=$branchPage&private_token=$personalAccessToken"
        try {
            $branchesPage = Invoke-RestMethod -Uri $uriBranches -Headers @{ "PRIVATE-TOKEN" = $personalAccessToken }
            if ($branchesPage -is [array] -and $branchesPage.Length -gt 0) {
                $allBranches += $branchesPage
                $branchPage++
            } else {
                $hasMoreBranches = $false
            }
        }
        catch {
            if ($_.Exception.Response.StatusCode -eq 403) {
                Write-Host "Project ${projectIndex}/${totalProjects}: 403 Forbidden Access: $($projectName) (ID: $projectId)" -ForegroundColor Red
                $hasMoreBranches = $false
            } else {
                throw
            }
        }
    }

    $pluralbranch = if ($allBranches.Length -ge 2) { "branches" } else { "branch" }
    Write-Host "Project ${projectIndex}/${totalProjects}: $($projectName) (ID: $projectId) $($allBranches.Length) $pluralbranch"

    # Parallelize branches (inner loop)
    $allBranches | ForEach-Object -Parallel {
        $branchName = $_.name
        $projectId = $using:projectId
        $sinceDate = $using:sinceDate
        $untilDate = $using:untilDate
        $personalAccessToken = $using:personalAccessToken
        $commitsPerPage = 100
        # Pagination for commits
        $allCommits = @()
        $commitPage = 1
        $hasMoreCommits = $true
        while ($hasMoreCommits) {
            $commitsUrl = "https://gitlab.com/api/v4/projects/$projectId/repository/commits?ref_name=$branchName&since=$sinceDate&until=$untilDate&per_page=$commitsPerPage&page=$commitPage&private_token=$personalAccessToken"
            $commitsPage = Invoke-RestMethod -Uri $commitsUrl -Headers @{ "PRIVATE-TOKEN" = $personalAccessToken }
            if ($commitsPage -is [array]) {
                if ($commitsPage.Length -gt 0) {
                    $allCommits += $commitsPage
                    $commitPage++
                } else {
                    $hasMoreCommits = $false
                }
            } elseif ($commitsPage) {
                $allCommits += $commitsPage
                $hasMoreCommits = $false
            } else {
                $hasMoreCommits = $false
            }
        }
        $commitCount = $allCommits.Length
        if ($commitCount -ne 0) {
            Write-Host "`e[93m   From branch: $branchName`e[0m"
            $allCommits | ForEach-Object {
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
    } -ThrottleLimit 5
} -ThrottleLimit 5


Write-Host ""
& $env:USERPROFILE\Documents\PowerShell\Get-RepoCount.ps1 -RepoCount $currentRepoCount -PrevCount $previousRepoCount
Write-Host ""
Write-Host "`e[1;32mGitLab check complete. ✔️`e[0m"
Write-Host ""
