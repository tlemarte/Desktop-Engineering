#create hostname file
$FilePath = "C:\Temp\$($MyInvocation.MyCommand.Name).txt"
if (!(Test-Path -path $FilePath)) {
    New-Item -Path $Filepath
}

#Open Notepad and wait for it to close
Start-Process notepad.exe $FilePath -wait

#Read the text file and clean up spaces and extra carriage returns
$Computers = Get-Content -Path $FilePath | Foreach {$_.TrimEnd()} | Where-Object {$_ -ne ""}
$i = 0

$Computers | ForEach-Object -process {
    Write-Progress -Activity "Scanning for logins..." `
        -CurrentOperation "Scanning $_" `
        -Status "Scanned: $i of $($Computers.Count)" `
        -PercentComplete (($i / $Computers.Count)  * 100)
    if (Test-Connection $_ -Count 1 -Quiet) {
        $CurrentUser = (Get-WMIObject -class Win32_ComputerSystem -ComputerName $_| select username).username
        $RC = Get-WinEvent -Computer $_ -FilterHashtable @{ Logname = ‘Security’; ID = 4672 } -MaxEvents 1 | Select @{ N = ‘User’; E = { $_.Properties[1].Value } }, TimeCreated
        write-host ($RC).Username -ForegroundColor DarkGreen -BackgroundColor White
        write-host $RC.TimeCreated -ForegroundColor DarkGreen -BackgroundColor White
        if ($CurrentUser -eq $null){
            Write-Host "$_ no user is currently logged on" -ForegroundColor DarkGreen -BackgroundColor White
        } else {
            Write-Host "$_ current user is" $CurrentUser -ForegroundColor DarkGreen -BackgroundColor White
        } 
    } else {
        Write-host  "`n $_ is not currently online" -ForegroundColor DarkRed -BackgroundColor White
    }
    $i++
}

Read-Host -Prompt "Press Enter to exit"