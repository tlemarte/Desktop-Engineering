#create input file
$FilePath = "C:\Temp\$($MyInvocation.MyCommand.Name).txt"
if (!(Test-Path -path $FilePath)) {
    New-Item -Path $Filepath
}

#Open Notepad and wait for it to close
Start-Process notepad.exe $FilePath -wait

#Read the text file and clean up spaces and extra carriage returns
$Computers = Get-Content -Path $FilePath | ForEach-Object {$_.TrimEnd()} | Where-Object {$_ -ne ""}
$i = 0

$Computers | ForEach-Object -process {
    Write-Progress -Activity "Scanning for Windows 10 Computers..." `
        -CurrentOperation "Scanning $_" `
        -Status "Scanned: $i of $($Computers.Count)" `
        -PercentComplete ($i / $($Computers.Count)  * 100)
    if (Test-Connection $_ -Count 1 -Quiet) {
        $OSWin32_OS = Get-WmiObject -Query "SELECT * FROM Win32_OperatingSystem" -ComputerName $_ -ErrorAction SilentlyContinue | Select-Object caption
	    $OSCaption = ($OSWin32_OS).Caption
        if ($OSCaption -eq "Microsoft Windows 10 Enterprise"){Write-Host $_}
    }
    $i++
}

Read-Host -Prompt "Press Enter to exit"


#Inefficient, has to wait for failed ping replies. Can multithread with runspace pools