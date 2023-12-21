
if (-not (Get-Module -Name platyPS)) {
    if (-not (Get-Module -Name platyPS -ListAvailable)) {
        $null = Install-Module platyPS -Force -AllowClobber
    }
}

Import-Module platyPS -Force

Import-Module "$PSScriptRoot\ModuleName\ModuleName.psd1" -Force

New-MarkdownHelp -Module ModuleName -OutputFolder .\Docs

Remove-Module ModuleName