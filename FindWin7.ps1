#create hostname file
$FilePath = "C:\Temp\FindWin7.txt"
if (!(Test-Path -path $FilePath)) {
    New-Item -Path $Filepath
}

#Open Notepad and wait for it to close
Start-Process notepad.exe $FilePath -wait

#Read the text file and clean up spaces and extra carriage returns
$Computers = Get-Content -Path $FilePath | Foreach {$_.TrimEnd()} | Where-Object {$_ -ne ""}

Write-Host "The following Hostnames are NOT on Windows 10"
$Computers | ForEach-Object -process {
    if (Test-Connection $_ -Count 1 -Quiet) {
        $OSWin32_OS = Get-WmiObject -Query "SELECT * FROM Win32_OperatingSystem" -ComputerName $_ -ErrorAction SilentlyContinue
	    $OSCaption = ($OSWin32_OS|Select-Object caption).Caption
        if (($OSCaption -ne "Microsoft Windows 10 Enterprise") -and ($OSCaption -ne $null)) {Write-Host $_}
    }
}
Write-Host "Finished"
Pause

#Inefficient, has to wait for failed ping replies. Can hyperthread with runspace pools

# $_ is "the variable in the pipeline"