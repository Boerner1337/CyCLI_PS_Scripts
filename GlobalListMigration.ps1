<#
Script to migrate the Global Blacklist
from one tenant to another. 
#>

$Source = Get-CyAPI EMEASE -Scope None
$Dest = Get-CyAPI MASTERS -Scope None


<#
    Legacy consoles sometimes contain strings that cannot be written with current console releases
#>
function ToSafeString() {
    Param(
        [parameter(Mandatory=$true,Position=1)]
        [string]$String
    )

    $String -replace "[&<>]","_"
}

# Migrate Global List
Write-Host "Migrating global quarantine list"
$DestList = Get-CyGlobalList -List GlobalQuarantineList -API $Dest
Get-CyGlobalList -API $Source -List GlobalQuarantineList | ForEach-Object { 
    if (! ($DestList.sha256 -contains $_.sha256)) {
        Write-Host "Adding hash $($_.sha256) to global quarantine list in destination"
        Add-CyHashToGlobalList -List GlobalQuarantineList -SHA256 $_.sha256 -Reason "Global Blacklist" -API $Dest
    }
}


