#
# Script module for module 'TcXaeMgmt'
#
Set-StrictMode -Version Latest

# Summary: TcXaeMgmt is supported on Windows PowerShell 5.1 or later and PowerShell 6.0+ / 7.0+

$isCore = ($PSVersionTable.Keys -contains "PSEdition") -and ($PSVersionTable.PSEdition -ne 'Desktop')
Write-Verbose "IsCore: $isCore"
$psVersion = $PSVersionTable.PSVersion
Write-Verbose "PSVersion: $psVersion"

if ($psVersion -ge [Version]'7.3')
{
    $script:Framework = 'netstandard2.0'
    $script:FrameworkToRemove = 'net462','net60'
}
elseif ($psVersion -ge [Version]'7.2')
{
    $script:Framework = 'netstandard2.0'
    $script:FrameworkToRemove = 'net462','net60'
}
elseif ($psVersion -ge [Version]'7.0')
{
    $script:Framework = 'netstandard2.0'
    $script:FrameworkToRemove = 'net462','net60'
} 
elseif ($psVersion -ge [Version]'6.0') 
{
    $script:Framework = 'netstandard2.0'
    $script:FrameworkToRemove = 'net462','net60'
}
else {
    
    $script:Framework = 'netstandard2.0'
    $script:FrameworkToRemove = 'net462','net60'
}

# Set up some helper variables to make it easier to work with the module
$script:PSModule = $ExecutionContext.SessionState.Module
$script:PSModuleRoot = $script:PSModule.ModuleBase
$script:PSMainAssembly = 'TwinCAT.Management.dll'

## CONSTRUCT A PATH TO THE CORRECT ASSEMBLY
$pathToAssembly = [io.path]::combine($PSScriptRoot, $script:Framework, $script:PSMainAssembly)
$pathToFramework = Join-Path -Path $script:PSModuleRoot -ChildPath $script:Framework
$pathToAssembly = Join-Path -Path $pathToFramework -ChildPath $script:PSMainAssembly

## Remove framework binaries that are not needed
#$FrameworkToRemovePath = Join-Path -Path $script:PSModuleRoot -ChildPath $script:FrameworkToRemove
#if (Test-Path $FrameworkToRemovePath)
#{
#    Remove-Item $FrameworkToRemovePath -Force -Recurse
#}

# NOW LOAD THE APPROPRIATE ASSEMBLY
Write-Verbose "Loading assembly '$pathToAssembly'"
$importedModule = Import-Module -Name $pathToAssembly -PassThru

#Set-Alias
New-Alias -Name AdsRead -Value  Read-TcValue -Scope Global -Force
New-Alias -Name AdsWrite -Value Write-TcValue -Scope Global -Force
New-Alias -Name AdsReadWrite -Value Send-TcReadWrite -Scope Global -Force
