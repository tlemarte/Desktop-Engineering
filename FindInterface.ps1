#create hostname file
$FilePath = "C:\Temp\$($MyInvocation.MyCommand.Name).txt"
if (!(Test-Path -path $FilePath)) {
    New-Item -Path $Filepath
}

#Open Notepad and wait for it to close
Start-Process notepad.exe $FilePath -wait

#Read the text file and clean up spaces and extra carriage returns
$Computers = Get-Content -Path $FilePath | ForEach-Object {$_.TrimEnd()} | Where-Object {$_ -ne ""}
$i = 0

Write-Host "The following Hostnames are on these network interfaces:"
$Computers | ForEach-Object -process {
        Write-Progress -Activity "Scanning for network interfaces..." -Status "Scanned: $i of $($Computers.Count)" -CurrentOperation "Scanning $_" -PercentComplete (($i / $Computers.Count)  * 100)
    if (Test-Connection $_ -Count 1 -Quiet) {
        #netconnectionstatus = 2 means that it is currently being used
        $ActiveInterface = (get-wmiobject win32_networkadapter -filter "netconnectionstatus = 2" -ComputerName $_ -ErrorAction SilentlyContinue).name 
        if ($ActiveInterface -ne $null) {
            write-host "$_ : $ActiveInterface"
        } else {
            write-host "$_ : Unable to query interface"
        }
    } else {
        write-host "$_ : Unreachable"
    }
    $i++
}

Write-Host "Finished"
Pause