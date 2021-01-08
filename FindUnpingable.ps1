#create hostname file
$FilePath = "C:\Temp\FindUnpingable.txt"
if (!(Test-Path -path $FilePath)) {
    New-Item -Path $Filepath
}

#Open Notepad and wait for it to close
Start-Process notepad.exe $FilePath -wait

#Read the text file and clean up spaces and extra carriage returns
$Computers = Get-Content -Path $FilePath | Foreach {$_.TrimEnd()} | Where-Object {$_ -ne ""}

Write-Host "The following Hostnames are unreachable"
$Computers | ForEach-Object -process {
    if (!(Test-Connection $_ -Count 1 -Quiet)) {
        write-host "Cant ping $_"
    }
}
Write-Host "Finished"
Pause