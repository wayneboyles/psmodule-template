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

Task Default -depends Test

Task Init {
    Set-Location $ProjectRoot
    Get-Item Env:BH*
    "`n"
}

Task Test -depends Init {

    # Testing links on github requires >= tls 1.2
    $SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Gather test results. Store them in a variable and file
    $TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile"
    [Net.ServicePointManager]::SecurityProtocol = $SecurityProtocol

    If ($ENV:BHBuildSystem -eq 'AppVeyor') {
        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", "$ProjectRoot\$TestFile")
    }

    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue

    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if ($TestResults.FailedCount -gt 0) {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
}

Task Build -depends Init {
    Set-ModuleFunctions -Name $Env:BHPSModuleManifest

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