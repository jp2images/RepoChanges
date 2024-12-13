<# 
.SYNOPSIS
    Write the search criteria to the console.
.DESCRIPTION
    This function will write the search criteria to the console. The search criteria
    will include the alias for the repository system, the number of days to search, 
    and whether the search is for one day or multiple days.

.PARAMETER repo
        The alias for the repository system. Default is "AzD".
.PARAMETER days
        The number of days to search for changes. Default is 1.
#>

param (
    [string]$repo,
    [int]$searchDays
)

if ($searchDays -ge 2) {
    $searchDescription = "for all changes in the previous $searchDays days."
} else { 
    $searchDescription = "for all changes in the previous day."
}

Write-Host "--------------------------------------------------------------------------------"
Write-Host "Checking the Azure DevOps Repositories using the Alias '$repo'"
Write-Host $searchDescription
Write-Host "--------------------------------------------------------------------------------" 
