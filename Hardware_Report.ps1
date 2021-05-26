<#
.SYNOPSIS
Hardware Inventory PS Script.

.DESCRIPTION
The script collects hardware information on the host computer by querying WMI classes. 

.PARAMETER ImputFile
The path including file name, which contains a list of computer names or IP addresses to be processed.

.PARAMETER OutputFile
The path including file name, to be created as a Hardware report file.

.INPUTS
<String>

.OUTPUTS
CSV file format.
  
.NOTES
Version:        0.1
Creation Date:  22/02/2021
Author:         Filipe Soares
Github Repo:	https://github.com/MyTech78/Hardware_report_PowerShell.git
Description:	First version of PowerShell script to generate a CSV hardware report by querying WMI.
  
.EXAMPLE
	.\Hardware_Report.ps1

	If running script with no argument switches please ensure you have a computer.txt file 
in the same location as the script, this is the list of computer names or IP addresses
to query, once the script has finished a computerReport.csv file will be created in the
same location.

.EXAMPLE
	.\Hardware_Report.ps1 -ImputFile ".\Computers.txt" -OutputFile ".\computerReport.csv"

	assuming you are in the correct path in PowerShell
and the Computers.txt is in the same folder as the Hardware_Report.ps1
then the computerReport.csv will be generated in the same location.

.EXAMPLE
	.\Hardware_Report.ps1 -ImputFile "c:\temp\Computers.txt" -OutputFile "c:\temp\computerReport.csv"

	Using the full path for the parameters.

#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
#$ErrorActionPreference = "SilentlyContinue"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# declaration of parameters
param(
[Parameter()]
[string]$ImputFile,
[Parameter()]
[string]$OutputFile
)

# set default values for imput file
if ($ImputFile -eq ""){
	$iFile = "Computers.txt"
	$Path = Split-Path $MyInvocation.MyCommand.Path -Parent
	$ImputFile = $Path + "\" + $iFile
}

# set default values for output file
if ($OutputFile -eq ""){
	$oFile = "ComputerReport.csv"
	$Path = Split-Path $MyInvocation.MyCommand.Path -Parent
	$OutputFile = $Path + "\" + $oFile
}

# check if imput file exists
if (Test-Path $ImputFile){
	# collect the list of computers from file to query.
	$arrComputers = Get-Content -Path $ImputFile
}
else {
	Write-Host "The Computers.txt file does not exist, this needs to be specified as an argument when running the script" -ForegroundColor white -BackgroundColor red
	Write-Host "or be placed in the same folder as the script, for more info type Get-Help Hardware_Report.ps1 -detailed" -ForegroundColor white -BackgroundColor red
}



# initialise report array
$Report = @()

#-----------------------------------------------------------[Functions]------------------------------------------------------------



#-----------------------------------------------------------[Execution]------------------------------------------------------------

# loop through the list of computers collecting WMI class information
foreach ($strComputer in $arrComputers){

    # New CimSecion
    $CimS = New-CimSession -ComputerName $strComputer -Authentication Negotiate

    # Get Cim Info
	$ComputerSystem_colItems = Get-CimInstance -ClassName Win32_ComputerSystem -Namespace 'root\CIMV2' -CimSession $CimS
	$BIOSInfo_colItems = Get-CimInstance -ClassName Win32_BIOS -Namespace 'root\CIMV2' -CimSession $CimS
	$OSInfo_colItems = Get-CimInstance -ClassName Win32_OperatingSystem -Namespace 'root\CIMV2' -CimSession $CimS
	$CPUInfo_colItems = Get-CimInstance -ClassName Win32_Processor -Namespace 'root\CIMV2' -CimSession $CimS
	$DiskInfo_colItems = Get-CimInstance -ClassName Win32_DiskDrive -Namespace 'root\CIMV2' -CimSession $CimS
	$Network_colItems = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Namespace 'root\CIMV2'-CimSession $CimS | Where-Object {$_.IPEnabled -eq 'True'}
	
	
	# order and filter the WMI info for the report
	$hash = [ordered]@{
		'Compute Name' = $OSInfo_colItems.CSname
		'Computer Manufacturer' = $ComputerSystem_colItems.Manufacturer
		'Computer Model' = $ComputerSystem_colItems.Model
		'Memory Size GB' = ("{0:N2}" -F ($ComputerSystem_colItems.TotalPhysicalMemory/1GB))
		'BIOS' = $BIOSInfo_colItems.Description
		'BIOS Version' = $BIOSInfo_colItems.SMBIOSBIOSVersion + '.' + $BIOSInfo_colItems.SMBIOSMajorVersion + '.' + $BIOSInfo_colItems.SMBIOSMinorVersion
		'Serial Number' = $BIOSInfo_colItems.SerialNumber
		'Operating System' = $OSInfo_colItems.Caption
		'Processor' = $CPUInfo_colItems.Name
		'Disk Model' = $DiskInfo_colItems.Model
		'Disk Size GB' = ("{0:N2}" -F ($DiskInfo_colItems.Size/1GB))
		'Disk Media Type' = $DiskInfo_colItems.MediaType
		'DHCP Enabled' = $Network_colItems.DHCPEnabled[0]
		'IPv4 Address' = $Network_colItems.IPAddress[0]
		'IPv6 Address' = $Network_colItems.IPAddress[1]
		'Subnet Mask:' = $Network_colItems.IPSubnet[0]
		'Gateway' = $Network_colItems.DefaultIPGateway[0]
		'MAC Address1' = $Network_colItems.MACAddress[0]
		
		}
	
	# create a new object for each computer with the hashed information 
	$Object = New-Object PSObject -Property $hash
	
	# append each object to the report array
	$Report += $Object

    # Remove CimSession for this host 
    Remove-CimSession $CimS
}

# export the report to a csv file 
$Report | Export-Csv $OutputFile -NoTypeInformation
