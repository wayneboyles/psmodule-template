$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
$ModuleRoot = Split-Path (Resolve-Path "$ProjectRoot\*\*.psm1")
$ModuleName = [System.IO.Path]::GetFileNameWithoutExtension((Split-Path (Resolve-Path "$ProjectRoot\*\*.psm1") -Leaf))

Describe "General Project Validation For: $ModuleName" {

    $Scripts = Get-ChildItem $ProjectRoot -Include *.ps1, *.psm1, *.psd1 -Recurse

    $TestCases = $Scripts | ForEach-Object { @{ File = $_ } }

    It "Script <File> Should Be Valid PowerShell" -TestCases $TestCases {
        param($File)

        $File.FullName | Should Exist

        $Contents = Get-Content -Path $File.FullName -ErrorAction Stop

        $Errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($Contents, [Ref] $Errors)
        $Errors.Count | Should Be 0
    }

    It "Module Can Import Cleanly" {
        { Import-Module (Join-Path $ModuleRoot "$ModuleName.psm1") -Force } | Should Not Throw
    }

}