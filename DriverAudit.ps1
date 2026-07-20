<#
.SYNOPSIS
    Windows Driver Audit Tool

.DESCRIPTION
    Audits installed Windows drivers, identifies outdated or problematic drivers,
    and generates reports for system maintenance.

.AUTHOR
    Justin Maddox

.VERSION
    1.0
#>

$Project = "Windows Driver Audit Tool"
$Version = "1.0"
$Author = "Justin Maddox"
$ScanStartTime = Get-Date
$ReportGenerated = Get-Date
$ScanStartTime = Get-Date

$script:Warnings = [System.Collections.Generic.List[string]]::new()
$script:Report = @{
    Drivers = @()
    ProblemDevices = @()
}

<#
.SYNOPSIS
    Collects installed Windows driver information.

.DESCRIPTION
    Retrieves installed Plug and Play drivers from the local computer
    and collects driver details including device name, manufacturer,
    version, installation date, and driver age.

    This information is stored in the report object for auditing
    and future HTML report generation.

.OUTPUTS
    System.Collections.Hashtable

    Returns driver information including:
    - Device name
    - Manufacturer
    - Driver version
    - Driver date
    - Driver age

.NOTES
    Author: Justin Maddox
    Project: Windows Driver Audit Tool
    Version: 1.0
#>
function Show-DriverInformation
{
    Write-Host "===== Driver Information ====="

    # Retrieve installed Plug and Play drivers from Windows
    $Drivers = Get-CimInstance Win32_PnPSignedDriver |
    Where-Object {
        $_.DeviceName -and
        $_.Manufacturer -and
        $_.DriverVersion
    }

    # Sort drivers by manufacturer and device name
    $Drivers = $Drivers | Sort-Object Manufacturer, DeviceName

    Write-Host ""
    Write-Host "Drivers Found: $($Drivers.Count)"
    Write-Host ""

    foreach ($Driver in $Drivers)
    {
        Write-Host ""

        Write-Host "Device: $($Driver.DeviceName)"
        Write-Host "Manufacturer: $($Driver.Manufacturer)"
        Write-Host "Driver Version: $($Driver.DriverVersion)"
        Write-Host "Driver Date: $($Driver.DriverDate)"

        # Store driver information for reports
        $script:Report.Drivers += @{
            Device = $Driver.DeviceName
            Manufacturer = $Driver.Manufacturer
            Version = $Driver.DriverVersion
            Date = $Driver.DriverDate
        }
    }

    Write-Host ""
}

<#
.SYNOPSIS
    Detects Windows devices with driver or hardware issues.

.DESCRIPTION
    Retrieves Plug and Play device information and identifies devices
    that are reporting errors or abnormal statuses.

    Problem devices are stored in the report object for auditing
    and future report generation.

.OUTPUTS
    System.Collections.Hashtable

    Returns device information including:
    - Device name
    - Status
    - Problem code
    - Class

.NOTES
    Author: Justin Maddox
    Project: Windows Driver Audit Tool
    Version: 1.0
#>

function Show-ProblemDevices
{
    Write-Host "===== Problem Device Detection ====="

    # Retrieve all Plug and Play devices installed on the system
    $Devices = Get-PnpDevice

    # Create storage location for problem devices
    $script:Report.ProblemDevices = @()

    # Filter devices that are not working correctly
    $ProblemDevices = $Devices | Where-Object {
        $_.Status -in @(
            "Error",
            "Problem",
            "Unknown"
        ) -and

        $_.Present -eq $true
    }

    if ($ProblemDevices.Count -eq 0)
    {
        Write-Host "No problem devices detected." -ForegroundColor Green
    }
    else
    {
        Write-Host "Problem devices detected: $($ProblemDevices.Count)" -ForegroundColor Yellow

        foreach ($Device in $ProblemDevices)
        {
            Write-Host ""

            Write-Host "Device: $($Device.FriendlyName)"
            Write-Host "Status: $($Device.Status)"
            Write-Host "Class: $($Device.Class)"

            # Store detected issues for reporting
            $script:Report.ProblemDevices += @{
                Device = $Device.FriendlyName
                Status = $Device.Status
                Class = $Device.Class
                Manufacturer = $Device.Manufacturer
            }

            # Add warning for detected device problems
            $script:Warnings.Add(
                "Device issue detected: $($Device.FriendlyName)"
            )
        }
    }

    Write-Host ""
}

<#
.SYNOPSIS
    Displays a summary of the driver audit results.

.DESCRIPTION
    Summarizes the results of the driver audit by displaying the total
    number of drivers scanned, driver health statistics, problem device
    count, and the overall audit status.

.OUTPUTS
    None

.NOTES
    Author: Justin Maddox
    Project: Windows Driver Audit Tool
    Version: 1.0
#>
function Show-DriverAuditSummary
{
    Write-Host ""
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host "     DRIVER AUDIT SUMMARY"
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host ""

    # Count total drivers detected
    $TotalDrivers = $script:Report.Drivers.Count

    # Count Microsoft drivers
    $MicrosoftDrivers = (
        $script:Report.Drivers |
        Where-Object {
            $_.Manufacturer -eq "Microsoft"
        }
    ).Count

    # Count third-party drivers
    $ThirdPartyDrivers = (
        $script:Report.Drivers |
        Where-Object {
            $_.Manufacturer -ne "Microsoft"
        }
    ).Count

    # Count problem devices
    $ProblemDevices = $script:Report.ProblemDevices.Count


    # Determine overall audit status
    if ($ProblemDevices -gt 0)
    {
        $OverallStatus = "WARNING"
        $StatusColor = "Yellow"
    }
    else
    {
        $OverallStatus = "HEALTHY"
        $StatusColor = "Green"
    }


    Write-Host "Total Drivers:        $TotalDrivers"
    Write-Host "Microsoft Drivers:    $MicrosoftDrivers"
    Write-Host "Third-Party Drivers:  $ThirdPartyDrivers"
    Write-Host ""
    Write-Host "Problem Devices:      $ProblemDevices"
    Write-Host ""
    Write-Host "Overall Status:       $OverallStatus" -ForegroundColor $StatusColor


    Write-Host ""
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host ""
}

function Export-DriverAuditReport
{
    Write-Host ""
    Write-Host "Generating HTML Report..."

    $ReportPath = "$env:USERPROFILE\Downloads\Driver-Audit-Report.html"

    $HTML = @"
<!DOCTYPE html>
<html>

<head>

<title>$Project</title>

<style>

body {
    font-family: Arial, sans-serif;
    margin: 40px;
    background-color: #f4f4f4;
}

h1 {
    color: #333;
}

.card {
    background:white;
    padding:20px;
    margin-bottom:20px;
    border-radius:8px;
}

table {
    width:100%;
    border-collapse:collapse;
    background:white;
}

th {
    background:#333;
    color:white;
    padding:10px;
    text-align:center;
}

td {
    padding:8px;
    border-bottom:1px solid #ddd;
    text-align:center;
}

.warning {
    color:#cc8800;
}

.pass {
    color:green;
}

</style>

</head>


<body>

<h1>$Project</h1>

<div class="card">

<h2>Report Information</h2>

<p>
<strong>Version:</strong> $Version
</p>

<p>
<strong>Author:</strong> $Author
</p>

<p>
<strong>Scan Started:</strong> $ScanStartTime
</p>

<p>
<strong>Report Generated:</strong> $ReportGenerated
</p>

</div>

<div class="card">

<h2>Summary</h2>

<p>
Scan Date:
$($ScanStartTime)
</p>

<p>
Total Drivers:
$($script:Report.Drivers.Count)
</p>

<p>
Problem Devices:
$($script:Report.ProblemDevices.Count)
</p>

</div>

"@

$HTML += @"

<div class="card">

<h2>Problem Devices</h2>

<table>

<tr>
<th>Device</th>
<th>Status</th>
<th>Class</th>
<th>Manufacturer</th>
</tr>

"@

foreach ($Device in $script:Report.ProblemDevices)
{
    $HTML += @"

<tr>

<td>$($Device.Device)</td>
<td>$($Device.Status)</td>
<td>$($Device.Class)</td>
<td>$($Device.Manufacturer)</td>

</tr>

"@
}

$HTML += @"

</table>

</div>

"@

$HTML += @"

<div class="card">

<h2>Driver Inventory</h2>

<table>

<tr>
<th>Device</th>
<th>Manufacturer</th>
<th>Version</th>
<th>Date</th>
</tr>

"@

foreach ($Driver in $script:Report.Drivers)
{

$HTML += @"

<tr>

<td>$($Driver.Device)</td>
<td>$($Driver.Manufacturer)</td>
<td>$($Driver.Version)</td>
<td>$($Driver.Date)</td>

</tr>

"@

}

$HTML += @"

</table>

</div>

<div class="card">

<p style="text-align:center;">

Generated by $Project v$Version |
Author: $Author |
$ReportGenerated

</p>

</div>

</body>

</html>

"@

$HTML | Out-File $ReportPath -Encoding utf8

Write-Host "Report saved:"
Write-Host $ReportPath
}

Show-DriverInformation
Show-ProblemDevices
Show-DriverAuditSummary
Export-DriverAuditReport