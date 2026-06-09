# AD Windows Group Membership Audit

PowerShell script to audit membership of selected Windows Active Directory groups and export the results to a dated CSV file for audit and review purposes.

## Overview

This script queries selected Active Directory groups recursively and produces a combined CSV report containing user membership details for each group. It is intended for periodic access reviews of privileged or operational groups such as Domain Admins, SQL Admins, and Deployment Engineers.

The script reports:

- Members of configured AD groups
- Enabled and disabled user accounts
- Nested group warnings
- User display name
- SamAccountName
- Account enabled status
- Group membership source

## Default Groups Audited

By default, the script audits the following groups:

```powershell
Domain Admins
SQL Admins - Production
Deployment Engineers
```

Additional groups can be added by editing the `$Groups` array in the script.

## Requirements

- Windows PowerShell
- Active Directory PowerShell module
- Domain-joined machine or server with access to Active Directory
- Permissions to read group membership and user properties in AD
- Administrator privileges recommended

## PowerShell Module Requirement

The script imports the Active Directory module:

```powershell
Import-Module ActiveDirectory
```

If the module is not available, install the Remote Server Administration Tools, or run the script from a domain controller or management server where the module is already installed.

## Usage

1. Open PowerShell as Administrator.
2. Confirm the output directory exists:

```powershell
New-Item -ItemType Directory -Path C:\Temp -Force
```

3. Run the script:

```powershell
.\Audit-ADGroups.ps1
```

4. Review the generated CSV file in `C:\Temp`.

## Output

The script creates a single CSV file using the current month and year in the filename.

Example:

```text
C:\Temp\Domain Groups Audit Jun 2026.csv
```

The CSV includes the following columns:

| Column | Description |
| --- | --- |
| Group | The AD group being audited |
| DisplayName | User display name from Active Directory |
| SamAccountName | User logon name |
| Enabled | Boolean account enabled status |
| Status | Friendly status value: Enabled or Disabled |

## Nested Group Detection

The script uses recursive group membership lookup. If nested groups are detected, a warning is shown in the console.

Example:

```text
WARNING: Nested groups detected in Domain Admins
```

Nested group users are still included in the exported results because the script uses recursive membership resolution.

## Customising Groups

Edit the `$Groups` section to add or remove groups:

```powershell
$Groups = @(
    "Domain Admins",
    "SQL Admins - Production",
    "Deployment Engineers",
    "Another AD Group"
) | Sort-Object -Unique
```

## Example Console Output

```text
===== Domain Admins =====
Total Users   : 5
Enabled Users : 4
Disabled Users: 1

Combined audit CSV saved to:
C:\Temp\Domain Groups Audit Jun 2026.csv
```

## Notes

- The output file is overwritten if the script is run more than once in the same month.
- The script exports CSV, not native Excel `.xlsx` format.
- The `C:\Temp` directory must exist before running the script unless directory creation is added.
- Group names must match the Active Directory group names exactly.

## Suggested Filename

Recommended script filename:

```text
Audit-ADGroups.ps1
```

## Author

Alan O'Brien  
Version 2.0
