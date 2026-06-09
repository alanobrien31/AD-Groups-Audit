<#
.SYNOPSIS
    Audit who are member of Windows Groups in AD.
    Ver 2.0 Alan Obrien
    aobrien@ehs.com

.DESCRIPTION
    This script collects:
    - Members of key AD groups (Domain Admins, SQL Admins - Production, Deployment Engineers)
    - It will export the contents of each group to an excel sheet for Audit purposes (Sample - C:\Temp\Domain Groups Audit MMM YYYY.csv)
    - It will autoname the exported sheet with MMM YYYY automatically
    - It will list Enabled and Disabled Users
    - If you need to Audit more groups just add it to the $Groups Section of the script

    Must be run as Administrator.
#>
Import-Module ActiveDirectory

$Groups = @(
    "Domain Admins",
    "SQL Admins - Production",
    "Deployment Engineers"
) | Sort-Object -Unique

$DateStamp = Get-Date -Format "MMM yyyy"
$OutputPath = "C:\Temp\Domain Groups Audit $DateStamp.csv"

$AllResults = @()

foreach ($Group in $Groups) {

    Write-Host "`n===== $Group =====" -ForegroundColor Cyan

    $RawMembers = Get-ADGroupMember -Identity $Group -Recursive

    # Nested group warning
    $NestedGroups = $RawMembers | Where-Object { $_.objectClass -eq "group" }
    if ($NestedGroups) {
        Write-Host "WARNING: Nested groups detected in $Group" -ForegroundColor Yellow
        $NestedGroups | Select Name | Format-Table -AutoSize
    }

    $Users = $RawMembers |
        Where-Object { $_.objectClass -eq "user" } |
        Select-Object -Unique SamAccountName |
        ForEach-Object {
            Get-ADUser $_.SamAccountName -Properties Enabled, DisplayName
        }

    Write-Host "Total Users   : $($Users.Count)"
    Write-Host "Enabled Users : $(($Users | Where Enabled -eq $true).Count)" -ForegroundColor Green
    Write-Host "Disabled Users: $(($Users | Where Enabled -eq $false).Count)" -ForegroundColor Red

    $GroupResults = $Users | Select @{
            Name="Group"; Expression={$Group}
        },
        DisplayName,
        SamAccountName,
        Enabled,
        @{Name="Status";Expression={if ($_.Enabled){"Enabled"}else{"Disabled"}}}

    $AllResults += $GroupResults
}

# Export single CSV
$AllResults | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8

Write-Host "`nCombined audit CSV saved to:`n$OutputPath" -ForegroundColor Green
