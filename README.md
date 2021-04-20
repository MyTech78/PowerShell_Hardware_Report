# Hardware_report_PowerShell

DESCRIPTION
        
        The script collects hardware infrormation on the host computer by quering WMI classes.

SYNTAX
  
    Hardware_Report.ps1 [[-ImputFile] <String>] [[-OutputFile] <String>] [<CommonParameters>]
 
PARAMETERS  
    
    -ImputFile <String>
        The path including file name, that contains a list of computer names or IP addresses to be processed.

    -OutputFile <String>
        The path including file name, to be created as a Hardware report file.

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).
 
EXAMPLES
    
    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>.\Hardware_Report.ps1

    If running script with no argument switches please ensure you have a computer.txt file
    in the same location as the script, this is the list of computer names or IP addresses
    to query, once the script has finished a computerReport.csv file will be created in the
    same location.




     -------------------------- EXAMPLE 2 --------------------------

    PS C:\>.\Hardware_Report.ps1 -ImputFile ".\Computers.txt" -OutputFile ".\computerReport.csv"

    assuming you are in the the correct path in powershell
    and the Computers.txt is in the same folder as the Hardware_Report.ps1
    then the computerReport.csv will be generated in the same location.




      -------------------------- EXAMPLE 3 --------------------------

    PS C:\>.\Hardware_Report.ps1 -ImputFile "c:\temp\Computers.txt" -OutputFile "c:\temp\computerReport.csv"

    Using the full path for the parameters.


REMARKS

    To see the examples, type: "get-help Hardware_Report.ps1 -examples".
    For more information, type: "get-help Hardware_Report.ps1 -detailed".
    For technical information, type: "get-help Hardware_Report.ps1 -full".
