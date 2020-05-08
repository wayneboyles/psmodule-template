[CmdletBinding()]
Param
(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    $Task = "Default",

    [Parameter()]
    [ValidateSet("Local", "Remote")]
    $BuildLocation = "Local"
)

Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

if ("Local" -eq $BuildLocation) {

    # Building on our local dev box so no need to install the modules
    # again if they already exist

    if (!(Get-Module -Name psake -ListAvailable -ErrorAction SilentlyContinue)) {
        Install-Module psake -Force
    }

    if (!(Get-Module -Name PSDeploy -ListAvailable -ErrorAction SilentlyContinue)) {
        Install-Module PSDeploy -Force
    }

    if (!(Get-Module -Name BuildHelpers -ListAvailable -ErrorAction SilentlyContinue)) {
        Install-Module BuildHelpers -Force -AllowClobber
    }

    if (!(Get-Module -Name Pester -ListAvailable -ErrorAction SilentlyContinue)) {
        Install-Module Pester -Force -SkipPublisherCheck
    }

} else {

    # Building on a 'remote' system.   This could be a build server on your
    # network or a 3rd party such as AppVeyor.  In any case install the modules
    # to ensure they are up to date and available

    Install-Module psake, PSDeploy, BuildHelpers -AllowClobber
    Install-Module Pester -Force -SkipPublisherCheck

}

# Import required modules
Import-Module psake
Import-Module BuildHelpers

# Prepreare the build environment variables
Set-BuildEnvironment -Force

# Invoke the build script
Invoke-psake -buildFile .\psake.ps1 -taskList $Task -nologo

Exit ([int](-not $psake.build_success))