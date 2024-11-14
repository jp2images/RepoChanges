
param (
    [int]$queryDays = -3,
    # Read the access token (AT) from a file that isn't in the Git Repo. That 
    # would be a security problem putting secrets in a repo. PATs should also 
    # be per person and never shared so that there is traceability.
    [string]$atFilePath = "$env:USERPROFILE\.ssh\NCS-GitLab-at.txt"
)

$accessToken = Get-Content -Path $atFilePath -Raw

# Calculate the date for how far to look back for changes
$sinceDate = (Get-Date).AddDays($queryDays).ToString("yyyy-MM-ddTHH:mm:ssZ")
$untilDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")

Write-Host "--------------------------------------------------------------------------------"
Write-Host "--------------------------------- Start of log ---------------------------------"
Write-Host "--------------------------------------------------------------------------------"
Write-Host ""

# Set the GitLab API URL for projects
$projectsApiUrl = "https://gitlab.com/api/v4/projects?membership=true&private_token=$accessToken"

try {
    # Fetch all projects
    $projects = Invoke-RestMethod -Uri $projectsApiUrl -Method Get -Headers @{ "PRIVATE-TOKEN" = $accessToken }
}
catch {
    Write-Host "Error fetching projects: $_"
    throw
}

foreach ($project in $projects) {
    $projectId = $project.id
    Write-Host "********************************************************************************"
    Write-Host "Project Repository: $($project.name) (ID: $projectId)"
    Write-Host "********************************************************************************"

    # Set the GitLab API URL for branches
    $branchesApiUrl = "https://gitlab.com/api/v4/projects/$projectId/repository/branches?private_token=$accessToken"

    try {
        # Get all branches
        $branches = Invoke-RestMethod -Uri $branchesApiUrl -Headers @{ "PRIVATE-TOKEN" = $accessToken }
    }
    catch {
        Write-Host "Error fetching branches: $_"
        throw
    }

    # Loop through each branch and get commits
    foreach ($branch in $branches) {

        $branchName = $branch.name
        $commitsApiUrl = "https://gitlab.com/api/v4/projects/$projectId/repository/commits?ref_name=$branchName&since=$sinceDate&until=$untilDate&private_token=$accessToken"
    
        # Make the API request to get the commits
        $response = Invoke-RestMethod -Uri $commitsApiUrl -Headers @{ "PRIVATE-TOKEN" = $accessToken }
    
        Write-Host "Branch:    $branchName"
        Write-Host "--------------------------------------------------------------------------------"
        
        # Display the commits
        $response | ForEach-Object {  
            $short_id = $_.short_id
            $author = $_.author_name
            $created_at = $_.created_at
            $message = $_.message

            Write-Host "Commit ID: $short_id"
            Write-Host "Author:    $author"
            Write-Host "Date:      $created_at"
            Write-Host "Comment:   $message"
            Write-Host "-----"
        }
        Write-Host "--------------------------------------------------------------------------------"
    }
}


Write-Output ""
Write-Output "***************"
Write-Output "Script Complete"
Write-Output "***************"
Write-Output ""