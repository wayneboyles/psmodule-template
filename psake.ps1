Properties {
    $ProjectRoot = $ENV:BHProjectPath
    if (-not $ProjectRoot) {
        $ProjectRoot = Resolve-Path $PSScriptRoot
    }

    $Timestamp = Get-Date -UFormat "%Y%m%d-%H%M%S"

    $PSVersion = $PSVersionTable.PSVersion.Major

    $Verbose = @{ }

    if ($Env:BHCommitMessage -match "!verbose") {
        $Verbose = @{ Verbose = $true }
    }
}

Task Default -depends Build

Task Init {
    Set-Location $ProjectRoot
    Get-Item Env:BH*
    "`n"
}

Task Build -depends Init {
    Set-ModuleFunctions

    # Increase the module version
    try {
        $GalleryVersion = Get-NextNugetPackageVersion -Name $Env:BHProjectName -ErrorAction Stop
        $GithubVersion = Get-MetaData -Path $Env:BHPSModuleManifest -PropertyName ModuleVersion -ErrorAction Stop

        if ($GalleryVersion -ge $GithubVersion) {
            Update-MetaData -Path $Env:BHPSModuleManifest -PropertyName ModuleVersion -Value $GalleryVersion -ErrorAction Stop
        }
    } catch {
        "Failed to update version for '$env:BHProjectName': $_.`nContinuing with existing version."
    }
}

Task Deploy -depends Build {
    $Params = @{
        Path    = $Env:BHBuildOutput
        Force   = $true
        Recurse = $false
    }

    Invoke-PSDeploy @Verbose @Params
}