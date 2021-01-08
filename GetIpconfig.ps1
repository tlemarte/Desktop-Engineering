#create hostname file
$FilePath = "C:\Temp\Find.txt"
if (!(Test-Path -path $FilePath)) {
    New-Item -Path $Filepath
}

#Open Notepad and wait for it to close
Start-Process notepad.exe $FilePath -wait

#Read the text file and clean up spaces and extra carriage returns
$Computers = Get-Content -Path $FilePath | Foreach {$_.TrimEnd()} | Where-Object {$_ -ne ""}

Write-Host "The following is the Network information of each computer"
$Results = foreach ($Computer in $Computers) {
    if (Test-Connection $Computer -Count 1 -Quiet) {
        [pscustomobject]@{
            'Hostname' = $Computer
            'IP' = (@(Get-WmiObject Win32_networkadapterconfiguration -ComputerName $computer -filter 'ipenabled = "true"' | Select-Object -ExpandProperty IPAddress | Where-Object { $_ -match '(\d{1,3}\.){3}\d{1,3}' }) -join ',')
         }
    } else {
        write-host unable to reach 
    }
}
$table | ForEach {[PSCustomObject]$_} | Format-Table -AutoSize
write-host $table
Pause