function Get-LoggedOn {
    $Computer = read-host "Enter Computer name here"
    if (Test-Connection $Computer -Count 1 -Quiet) {
        $CurrentUser = (Get-CimInstance -class Win32_ComputerSystem -ComputerName $Computer| Select-Object username).username
        if ($null -eq $CurrentUser){
            Write-Host "No user is currently logged on" -ForegroundColor DarkGreen
        } else {
            Write-Host "Current user is" $CurrentUser -ForegroundColor DarkGreen
        }
    } else {
        Write-host "The device is not currently online" -ForegroundColor DarkRed
    }
} #End of GetLoggedOn

$complete = $false
do{
    Get-LoggedOn
    $CompleteCheck = read-host "Check another computer? (y/n)"
    if ($CompleteCheck -eq "n") {$complete = $true}
} while($complete -eq $false)