<#
.Synopsis
   This script scans various WMI properties from a list of computers, and makes decisions based off of the information
.NOTES
    Make a mark in Upgrades if it has been reached. Skip units that are win10
    If pingable, check win10
        If win10 update hardware. if upgrade = true
            TO DO : Read software list, check for installation and prompt to begin others
    Else, mark as stil win7/unreachable

#>

#-----Find Excel File to Edit-------------
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.initialDirectory = $pwd
$OpenFileDialog.filter = "Excel files (*.xlsx*)| *.xlsx*"
$OpenFileDialog.ShowDialog() | Out-Null
$FilePath = $OpenFileDialog.filename
#-----------------------------------------

#-----Opening Excel Object---------------- 
$Excel = New-Object -ComObject Excel.Application
$WorkBook = $Excel.Workbooks.Open($FilePath)
$WorkSheet = $WorkBook.Sheets.Item(1)
#----------------------------------------- 

#-----Initializing variables--------------
$TotalNumberOfRows = $WorkSheet.UsedRange.Rows.Count
Write-host "There is $TotalNumberOfRows rows"

$Row,$Column = 2,1
$Win10Column = 11
#----------------------------------------
do{
$HostName = $WorkSheet.Cells.Item($Row,$Column).text
write-host "Row $Row"
if ($WorkSheet.Cells.Item($Row,$Win10Column).text -eq "") { 
    write-host "Pinging $HostName"
    if(test-connection -ComputerName $HostName -Count 1 -quiet) {  
        write-host "Pinged $HostName, checking if on Windows 10"
        $OSWin32_OS = Get-WmiObject -Query "SELECT * FROM Win32_OperatingSystem" -ComputerName $HostName
        $OSCaption = ($OSWin32_OS|Select-Object caption).Caption
        try{
            if ($OSCaption -eq "Microsoft Windows 10 Enterprise") {
                Write-Host "$HostName updated to windows 10!" -ForegroundColor green -BackgroundColor black
                $WorkSheet.Cells.Item($Row,$Win10Column) = 1
            } else {
                Write-Host "$HostName is on windows 7"
            }
        } catch [Exception] { #If pinged but error during requests 
            write-host "Pinged $HostName, unable to query"
            $date = Get-Date -Format "dddd MM/dd/yyyy HH:mm K"
            $WorkSheet.Cells.Item($Row,3) = "RPC error on $date"
        }
    } else {
        write-host "No ping to $HostName"
        $date = Get-Date -Format "dddd MM/dd/yyyy HH:mm K"
        $WorkSheet.Cells.Item($Row,3) = "Can't ping on $date"
    }
} 
#Increment to next Row and reset Column
$Row ++
$Column = 1
} while ($Row -le $TotalNumberOfRows) #Go to next row, continues until all rows passed
 
#Make Excel visible  
#$Excel.Visible=$True | Out-Null 

#-----Clean up-------------------------
Write-Host "Saving file to $FilePath"  
$WorkBook.Save
$Excel.displayAlerts=$False 
$WorkBook.Close() 
$Excel.Quit() 
#--------------------------------------

