[CmdletBinding()]
Param
(
    $Task = "Default"
)

Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Install-Module psake, PSDeploy, BuildHelpers -AllowClobber
Install-Module Pester -Force -SkipPublisherCheck

Import-Module psake
Import-Module BuildHelpers

Set-BuildEnvironment

Invoke-psake -buildFile .\psake.ps1 -taskList $Task -nologo

Exit ([int](-not $psake.build_success))