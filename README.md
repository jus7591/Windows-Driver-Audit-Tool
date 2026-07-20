# Windows Driver Audit Tool

A PowerShell-based Windows driver auditing utility that inventories installed drivers, detects device issues, categorizes driver vendors, and generates an HTML-based audit report for troubleshooting and system documentation.

---

# Overview

The Windows Driver Audit Tool was created to automate the process of reviewing installed Windows drivers and identifying potential hardware-related issues.

The script collects driver information using built-in Windows management tools, analyzes connected devices for errors, and generates a technician-friendly HTML report containing driver inventory and problem device information.

This project demonstrates PowerShell automation, Windows administration, hardware troubleshooting, data collection, and report generation.

---

# Features

- Collects installed Windows driver inventory
- Retrieves driver information including:
  - Device name
  - Manufacturer
  - Driver version
  - Driver date
  - Validates driver digital signature information
  - Reports driver signing status and publisher information
- Filters incomplete driver records
- Categorizes drivers into:
  - Microsoft drivers
  - Third-party drivers
- Detects devices reporting hardware issues
- Identifies problem devices using Windows Plug and Play information
- Generates HTML audit reports
- Provides PowerShell console output for quick troubleshooting
- Stores collected information for future reporting expansion

---

# Architecture

The Windows Driver Audit Tool follows a modular PowerShell architecture designed to separate data collection, analysis, reporting, and output generation.

## Workflow Overview

```
+-----------------------------+
|        Main Program         |
|     DriverAudit.ps1         |
+-------------+---------------+
              |
              v
+-----------------------------+
|     Data Collection Layer   |
+-----------------------------+
| Show-DriverInformation      |
| Show-ProblemDevices         |
+-------------+---------------+
              |
              v
+-----------------------------+
|       Report Data Store     |
+-----------------------------+
| $script:Report              |
|                             |
| - Drivers                   |
| - ProblemDevices            |
+-------------+---------------+
              |
              v
+-----------------------------+
|       Analysis Layer        |
+-----------------------------+
| Show-DriverAuditSummary     |
|                             |
| - Driver Counts             |
| - Vendor Classification     |
| - Device Health Status      |
+-------------+---------------+
              |
              v
+-----------------------------+
|      Reporting Layer        |
+-----------------------------+
| Export-DriverAuditReport    |
|                             |
| - HTML Generation           |
| - Report Formatting         |
| - Results Presentation      |
+-------------+---------------+
              |
              v
+-----------------------------+
|        Final Output         |
+-----------------------------+
| PowerShell Console Output   |
| HTML Audit Report           |
+-----------------------------+
```

---

# Component Breakdown

## Main Program

The main execution block controls the order of operations and coordinates each audit function.

Responsibilities:

- Starts the audit process
- Executes collection functions
- Generates reports
- Displays final results

---

## Data Collection Layer

The data collection layer gathers information from the Windows operating system.

### Show-DriverInformation

Collects:

- Installed driver information
- Driver manufacturers
- Driver versions
- Driver dates
- Driver signing status
- Driver signer information


### Show-ProblemDevices

Collects:

- Device status
- Device class
- Manufacturer information
- Hardware issues reported by Windows

---

## Report Data Store

Collected information is stored in a centralized PowerShell object:

```powershell
$script:Report
```

Current data structure:

```
Report
│
├── Drivers
│   ├── Device
│   ├── Manufacturer
│   ├── Version
│   ├── Date
│   ├── Signed
│   └── Signer
│
└── ProblemDevices
    ├── Device
    ├── Status
    ├── Class
    └── Manufacturer
```

This allows collected information to be reused for multiple reporting formats.

---

## Analysis Layer

The analysis layer processes collected information and creates an audit summary.

Responsibilities:

- Counts total drivers
- Identifies Microsoft drivers
- Identifies third-party drivers
- Counts problem devices
- Determines overall audit status

Function:

```
Show-DriverAuditSummary
```

---

## Reporting Layer

The reporting layer converts collected data into an HTML report.

Function:

```
Export-DriverAuditReport
```

The generated report includes:

- Report metadata
- Driver audit summary
- Problem device information
- Driver inventory table

---

# Technologies Used

## PowerShell

Used for:

- Windows automation
- Hardware inventory collection
- Device health checks
- Data processing
- HTML report generation

## Windows Management Tools

The project uses built-in Windows tools including:

- `Get-CimInstance`
- `Win32_PnPSignedDriver`
- `Get-PnpDevice`
- PowerShell objects
- HTML string generation

---

# Report Preview

## Driver Audit Summary

The audit summary provides an overview of the system driver environment including total drivers, Microsoft drivers, third-party drivers, detected problems, and overall status.

![Driver Audit Summary](images/dashboard.png)


## Problem Device Detection

The tool identifies devices reported by Windows as having issues and provides troubleshooting information.

![Problem Devices](images/problem-devices.png)


## Driver Inventory

The driver inventory provides a complete list of detected drivers including manufacturer, version, and driver date.

![Driver Inventory](images/driver-inventory.png)

---

# Requirements

- Windows 10 or Windows 11
- Windows PowerShell 5.1+
- Administrator privileges recommended for complete hardware visibility

---

# Installation

Clone the repository:

```powershell
git clone https://github.com/jus7591/Windows-Driver-Audit-Tool.git
```

Navigate to the project directory:

```powershell
cd Windows-Driver-Audit-Tool
```

---

# Usage

Open PowerShell as Administrator.

Run:

```powershell
.\DriverAudit.ps1
```

The script will:

1. Collect installed driver information
2. Analyze connected devices
3. Generate an audit summary
4. Create an HTML report

---

# Example Output

```
=================================
     DRIVER AUDIT SUMMARY
=================================

Total Drivers:        256
Microsoft Drivers:    79
Third-Party Drivers:  177

Problem Devices:      1

Overall Status:       WARNING

=================================
```

---

# Project Structure

```
Windows-Driver-Audit-Tool
│
├── DriverAudit.ps1
├── README.md
├── images
│   ├── dashboard.png
│   ├── problem-devices.png
│   └── driver-inventory.png
└── .gitignore
```

---

# Future Improvements

Planned enhancements:

- CSV export for driver inventory and problem devices
- Additional driver health recommendations
- Improved HTML dashboard visualization
- Manufacturer-based driver reporting
- Automated driver update recommendations
- Driver comparison against approved baselines
- Historical audit comparison reports

---

# Skills Demonstrated

This project demonstrates experience with:

- PowerShell scripting
- Windows administration
- Hardware troubleshooting
- Driver management
- System inventory automation
- HTML report generation
- Data organization and reporting

---

# Author

**Justin Maddox**

Enterprise IT Professional specializing in Windows environments, hardware troubleshooting, infrastructure support, and automation.

GitHub:
https://github.com/jus7591