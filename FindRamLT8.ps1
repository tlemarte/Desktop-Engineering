#create hostname file
$FilePath = "C:\Temp\FindRamLT8.txt"
if (!(Test-Path -path $FilePath)) {
    New-Item -Path $Filepath
}

#Open Notepad and wait for it to close
Start-Process notepad.exe $FilePath -wait

#Read the text file and clean up spaces and extra carriage returns
$Computers = Get-Content -Path $FilePath | Foreach {$_.TrimEnd()} | Where-Object {$_ -ne ""}

Write-Host "The following Hostnames have less than 8gb of RAM:"
$Computers | ForEach-Object -process {
    if (Test-Connection $_ -Count 1 -Quiet) {
       $Memory = ((Get-WmiObject Win32_physicalmemory -ComputerName $_ -erroraction 'silentlycontinue' ).Capacity  | measure-object -sum).sum / 1GB -as [int] 
        #If memory comes back with a valid number and is less than 8, message
        if ($Memory -ne 0) { if ($Memory -lt 8) {
            write-host "$_ does not have 8gb of ram"
        }}
    }
}
Write-Host "Finished"
Pause