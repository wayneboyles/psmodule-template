
# ==========================================
# IMPORT SCRIPTS
# ==========================================

$Public  = @(Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue)

foreach($import in @($Public + $Private))
{
    try { . $import.fullname }
    catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# ==========================================
# VARIABLES
# ==========================================

# $MyModuleSession = [PSCustomObject] @{
#     ClientId = ""
#     Token = ""
#     BaseUrl = ""
# }

#New-Variable -Name MyModuleSession -Value $MyModuleSession -Scope Script -Force

# ==========================================
# EXPORT
# ==========================================

Export-ModuleMember -Function $Public.BaseName