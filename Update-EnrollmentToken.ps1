<#
.SYNOPSIS

Enrolls Falcon LogScale Collector on a Windows Client/Server

.DESCRIPTION

The Update-EnrollmentToken.ps1 enrolls the Falcon LogScale Collector on
an Windows Client/Server where the Falcon LogScale Collector is installed.

.PARAMETER EnrollmentToken
Specifie the EnrollmentToken found in the FleetManagement

.PARAMETER Wait
Set to $true and the script waits for 60 seconds to run. This can be used
if the installation is done in the same Group Policy than the enrollment.

.PARAMETER Seconds
Time befor the script starts the check of the installation. 

.INPUTS

None. You cannot pipe objects to Update-EnrollmentToken.ps1.

.OUTPUTS

None. Update-EnrollmentToken.ps1 does not generate any output.

.EXAMPLE

PS> .\Update-EnrollmentToken.ps1 -EnrollmentToken eyJpbnN0YWxsVG9rZW1iOiJUWWkjlViklXVhblJ3QU9WRWcwNFgyb09GeTR3WFVWNiIsInVybCI6Imh0dHBzOi8vY2xvdWQuaHVtaW8uY29tIn3

.EXAMPLE

PS> .\Update-EnrollmentToken.ps1 -EnrollmentToken eyJpbnN0YWxsVG9rZW1iOiJUWWkjlViklXVhblJ3QU9WRWcwNFgyb09GeTR3WFVWNiIsInVybCI6Imh0dHBzOi8vY2xvdWQuaHVtaW8uY29tIn3 -Wait -Seconds 30

#>

[CmdletBinding()]
param (
    # EnrollmenToken used for the enrollment
    [Parameter(Mandatory=$true, HelpMessage="The EnrollmentToken from the string inside the FleetManagement")]
    [string]
    [ValidateLength(100,150)]
    $EnrollmentToken,
    
    # Wait for 60 seconds
    [switch]
    $Wait = $false,

    # Wait time
    [Parameter(HelpMessage="Seconds to wait for the script to start")]
    [int]
    [ValidateRange(0,999)]
    $Seconds = 60
       
)
Start-Transcript -Path "C:\Windows\Temp\Update-EnrollmentToken.txt"

# Parameters
$DataFolder = "C:\ProgramData\LogScale Collector"
$FleetFolder = Join-Path $DataFolder "fleet"
$EnrollmentTokenFile = "token.json"
$ProgramPath = "C:\Program Files (x86)\CrowdStrike\Humio Log Collector\"
$Program = Join-Path $ProgramPath "humio-log-collector.exe"
$ConfigYaml = Join-Path $ProgramPath "config.yaml"

# wait for installation to complete
if ($Wait) {
    Start-Sleep -Seconds $Seconds
}

# Test if the program is installed
if (-not(Test-Path $Program)) {
    Write-Host "Log Collector is not installed"
    exit -1
}

# Test if the enrollment status is full
if (Get-Content $ConfigYaml | Select-String mode:) {
    Write-Host "Log Collector is already enrolled"
    exit -1
}

# Test if path is present
if (Test-Path -Path $FleetFolder) {
    Write-Host "DataFolder or FleetFolder are present."
    exit -1
}

# Test if EnrollmentTokenFile is present
if (Test-Path -Path $(Join-Path $FleetFolder $EnrollmentTokenFile)) {
    Write-Host "EnrollmentTokenFile is present."
    exit -1
}

# Enroll the Log Collector
$Arguments = "enroll $EnrollmentToken"

Start-Process -FilePath $Program -ArgumentList $Arguments
Write-Host "Enrollment successfull"

Stop-Transcript