<#
    .SYNOPSIS
        A tool for finding information about a list of hostnames
    .DESCRIPTION
        Made to compile multiple tools into one, and formatted to allow easy addition of more tools
    .NOTES
        Requires Powershell 7 or higher
        Split into 3 chunks.
        Initialization, sets up conditions needed later.
        Functions, where each set of actions is stored for readability
        Execution, where the magic happens
#>

#--------------------------------------------[Initializations]
#Create input file
$FilePath = "C:\Temp\SuperFinder.txt"
if (!(Test-Path -path $FilePath)) {
    [void](New-Item -Path $Filepath) #void hides output text
}

$Done = $false #For "While' loop 
#Set up Global Variables for Write-Progress
$Activity,$Status,$PercentComplete,$CurrentOperation,$Status,$i = 0

#--------------------------------------------------[Functions]
function Get-List {
    Write-Host "Notepad has opened, please enter a list of hostnames to run a tool against."
    Write-Host "There should be only one hostname per line. Save and close notepad when you're done."

    #Read the text file and clean up spaces and extra carriage returns
    Start-Process notepad.exe $FilePath -wait
    $global:CleanedList = Get-Content -Path $FilePath
        | ForEach-Object {$_.TrimEnd()}
            | Where-Object {$_ -ne ""}
    $global:CleanedListLength = $global:CleanedList.Count  
    Write-Host $global:CleanedListLength
}

function Show-Tree {
    Write-Host "Please enter the the characters for the tool you would like to run."
    Write-Host "00 ) - Enter a new list"
    Write-Host "01 ) - Find devices online and on windows 10"
    Write-Host "02 ) - Find devices online and not on windows 10"
    Write-Host "03 ) - Find devices that are offline/unreachable"
    Write-Host "04 ) - Find devices with less than 8gb of RAM"
    Write-Host "05 ) - Find the active internet interface of devices"
    Write-Host "06 ) - Find the current logged on users"
    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        '00' {Get-List}
        '01' {Find-Win10($global:CleanedList)}
        '02' {Find-NotWin10($global:CleanedList)}
        '03' {Find-Unreachable($global:CleanedList)}
        '04' {Find-RamLT8($global:CleanedList)}
        '05' {Find-Interface($global:CleanedList)}
        '06' {Find-LoggedOn($global:CleanedList)}
        default {Write-host "That is not a valid option"}
    }
}


function Find-Win10 {
    <#
    .SYNOPSIS
        Writes the hostnames of computers on windows 10
    .DESCRIPTION
        Sends a single ping, if the device is online, uses Cim to find OS caption. 
        If it is windows 10, write-host the name
    #>
    [CmdletBinding()]
    param (
        [Object[]]$Computers
    )

    process {
        $Computers | ForEach-Object -parallel {
            Write-Progress -Activity "Checking devices..." -Status "Checking: $_"
            if (Test-Connection $_ -Count 1 -Quiet) {
                $OSCaption = (Get-CimInstance -Query "SELECT * FROM Win32_OperatingSystem" -ComputerName $_ -ErrorAction SilentlyContinue).Caption
                if ($OSCaption -eq "Microsoft Windows 10 Enterprise"){Write-Host $_ -ForegroundColor DarkGreen}
            }
        }
    }
}

function Find-NotWin10 {
    [CmdletBinding()]
    param (
        [Object[]]$Computers
    )

    process {
        $Computers | ForEach-Object -parallel {
            Write-Progress -Activity "Search in Progress" -Status "$i% Complete:" -PercentComplete $i;
            if (Test-Connection $_ -Count 1 -Quiet) {
                $OSCaption = (Get-CimInstance -Query "SELECT * FROM Win32_OperatingSystem" -ComputerName $_ -ErrorAction SilentlyContinue).Caption
                if ($OSCaption -ne "Microsoft Windows 10 Enterprise"){Write-Host $_ -ForegroundColor DarkYellow}
            }
        }
    }
}
function Find-Unreachable {
    [CmdletBinding()]
    param (
        [Object[]]$Computers
    )

    process {
        $Computers | ForEach-Object -parallel {
            if (!(Test-Connection $_ -Count 1 -Quiet)) {Write-Host $_ -ForegroundColor DarkRed}
        }
    }
}

function Find-RamLT8 {
    [CmdletBinding()]
    param (
        [Object[]]$Computers
    )

    process {
        $Computers | ForEach-Object -Parallel {
            if (Test-Connection $_ -Count 1 -Quiet) {
               $Memory = ((Get-CimInstance Win32_physicalmemory -ComputerName $_ -erroraction 'silentlycontinue' ).Capacity
                | measure-object -sum).sum / 1GB -as [int] 
                #If memory comes back with a valid number and is less than 8, message
                if (($Memory -ne 0) -AND ($Memory -lt 8)) {write-host $_ -ForegroundColor DarkYellow}
            }
        }
    }
}
function Find-Interface {
    [CmdletBinding()]
    param (
        [Object[]]$Computers
    )

    process {
        $Computers | ForEach-Object -Parallel {
            if (Test-Connection $_ -Count 1 -Quiet) {
                #netconnectionstatus = 2 means that it is currently being used
                $ActiveInterface = (Get-CimInstance win32_networkadapter -filter "netconnectionstatus = 2" -ComputerName $_ -ErrorAction SilentlyContinue).name 
                if (![string]::IsNullOrEmpty($ActiveInterface)) {
                    write-host "$_ : $ActiveInterface" -ForegroundColor DarkGreen
                } else {
                    write-host "$_ : Unable to query interface" -ForegroundColor DarkRed
                }
            } else {
                write-host "$_ : Unreachable" -ForegroundColor DarkRed
            }
        }
    }
}
function Find-LoggedOn {
    [CmdletBinding()]
    param (
        [Object[]]$Computers
    )

    process {
        $Computers | ForEach-Object -Parallel {
            if (Test-Connection $_ -Count 1 -Quiet) {
                $CurrentUser = (Get-CimInstance -class Win32_ComputerSystem -ComputerName $_
                    | Select-Object username).username
                if ($null -eq $CurrentUser){
                    Write-Host "$_ no user is currently logged on" -ForegroundColor DarkGreen
                } else {
                    Write-Host "$_ current user is" $CurrentUser -ForegroundColor DarkGreen
                } 
            } else {
                Write-host  "$_ is not currently online" -ForegroundColor DarkRed
            }
        }
    }
}
#---------------------------------------------[Execution]
Get-List
while ($Done -eq $false) {
    Show-Tree
    $DoneResponse = Read-Host -Prompt "Run another tool? (Y/N)"
    if ($DoneResponse -match "[nN]" ) {$done = $true}
}