[CmdletBinding()]
Param()

Write-Verbose "Importing Functions..."

foreach ($folder in @('Enums', 'Classes', 'Private', 'Public')) {
    $root = Join-Path -Path $PSScriptRoot -ChildPath $folder

    if (Test-Path -Path $root) {
        Write-Verbose " - Importing $($Root)"

        $files = Get-ChildItem -Path $root -Filter *.ps1 -Recurse
        $files | Where-Object { $_.Name -notlike '*.Tests.ps1' } | ForEach-Object { Write-Verbose "   - Importing Function: $($_.BaseName)"; . $_.FullName }
    }
}

Export-ModuleMember -Function (Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1").BaseName