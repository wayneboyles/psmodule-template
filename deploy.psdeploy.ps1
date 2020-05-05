if ($Env:BHModulePath -and $Env:BHBuildSystem -ne 'Unknown' -and $Env:BHBranchName -eq 'Master' -and $Env:BHCommitMessage -match '!deploy') {

    Deploy Module {
        By PSGalleryModule {
            FromSource $Env:BHModulePath
            To PSGallery
            WithOptions @{
                ApiKey = $Env:PrivateNuGetApiKey
            }
        }
    }

} else {

    "Skipping deployment: To deploy, ensure that...`n" +
    "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" +
    "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" +
    "`t* Your commit message includes !deploy (Current: $ENV:BHCommitMessage)" | Write-Output

}

# Publish to AppVeyor
if ($Env:BHModulePath -and $Env:BHBuildSystem -eq 'AppVeyor') {

    Deploy DeveloperBuild {
        By AppVeyorModule {
            FromSource $Env:BHModulePath
            To AppVeyor
            WithOptions @{
                Version = $Env:APPVEYOR_BUILD_VERSION
            }
        }
    }

}