Write-host "Initializing Refresh Script"
#Get OS, Imprivata Policy, O365 version (for removal on shared policy)

write-host "Checking OS verison..."
$os = (Get-CimInstance -ClassName CIM_OperatingSystem).Caption

write-host "Checking Imprivata policy..."
IF ((gwmi win32_operatingsystem | Select-Object osarchitecture).osarchitecture -eq "64-bit") {
    $policy = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\WOW6432Node\SSOProvider\ISXAgent" -Name "Type"
} ELSE {
    $policy = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\SSOProvider\ISXAgent" -Name "Type"
} 
#1 = single/mud
#2 = shared

write-host "Checking 0365 configuration..."
$officeVersion = Get-ItemPropertyValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\O365ProPlusRetail*" -Name "DisplayVersion"

write-host "Initialization finished."

IF ($os -ne 'Microsoft Windows 10 Enterprise'){
    IF ($policy -eq "1"){
        #If single/MUD, PCmover and decommision
        IF (Test-Path \\Backup\Path\Goes\Here\$env:computername.pcv -eq 'True'){
            write-host "Opening decommision tool."
                & \\Decommision\Path\Goes\Here
        } ELSE {
            #Prompt to open PCMover
            $confirmation = Read-Host "No backup found, open PCMover? (y/n)"
            IF ($confirmation -eq 'y') {
                & \PCMover\Path\Goes\Here
            } ELSE {
                Write-Host "Opening decommission tool"
                & \\Decommision\Path\Goes\Here
            }
        }
    } ELSE {
        #If shared, backup last 2 months of users desktop/documents/favorites and decommision
        IF (Test-Path \\Backup\Path\Goes\Here\$env:computername.pcv -eq 'True'){
            write-host "Opening decommision tool."
                & \\Decommision\Path\Goes\Here
        } ELSE {
            #Prompt to backup last 2 months and decommission
            $confirmation = Read-Host "No backup found, backup last 2 months of users then decommission? (y/n)"
            IF ($confirmation -eq 'y') {
                $StartDate = (Get-Date).AddDays(-60)
                $StrSource = C:\Users
                $StrTarget = \\Backup\Path\Goes\Here\$env:username\$env:computername
                Get-ChildItem $StrSource | Where-Object {($_.LastWriteTime.Date -ge $StartDate.Date)} | Copy-Item -Destination $StrTarget -Recurse
                Write-Host "Opening decommission tool"
                & \\Decommision\Path\Goes\Here
            } ELSE {
                Write-Host "Opening decommission tool"
                & \\Decommision\Path\Goes\Here
            }
        }
    }
#Test if computer is not renamed
} ELSEIF (($env:COMPUTERNAME -Match "MININT") -eq $true) {
    $NewName = Read-Host "Enter the new Hostname (will be copied to clipboard)"
    Set-Clipboard -Value $NewName
    IF (Test-Connection -ComputerName $NewName -Quiet) { 
        [System.Windows.MessageBox]::Show('That hostname is currently in use!','Rename Warning')       
    } ELSE {
        & \\Rename\Path\Goes\Here\RenameComputer.exe 
    }
} ELSE {
    #If the device is shared, restore users, verify 0365 uninstalled, and run Autologon
    IF ($policy -eq "2") {
        
        #Restore 2month backups, NEEDS PERM
        Copy-Item \\Backup\Path\Goes\Here\$env:username\$env:computername -Destination C:\Users -Recurse 
        Write-Host "Backup copied to C:\Users"
        
        #If the room is an exam room, open device manager for assigning COM ports and citrix for midmark. NEEDS PERM to run script for doing COMs automatically
        IF (($env:COMPUTERNAME -Match "EXM") -eq $true) {
            $Name = "USB Serial Port"
            $NewPort = "COM1"

            #Queries WMI for Device
            $WMIQuery = 'Select * from Win32_PnPEntity where Description = "' + $Name + '"'
            $Device = Get-WmiObject -Query $WMIQuery
    
           Write-Host = $Device

            #Execute only if device is present
            if ($Device) {
	        	
    	        #Get current device info
    	        $DeviceKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\" + $Device.DeviceID
    	        $PortKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\" + $Device.DeviceID + "\Device Parameters"
               	$Port = get-itemproperty -path $PortKey -Name PortName
            	$OldPort = [convert]::ToInt32(($Port.PortName).Replace("COM",""))
        	
            	#Set new port and update Friendly Name
            	$FriendlyName = $Name + " (" + $NewPort + ")"
               	New-ItemProperty -Path $PortKey -Name "PortName" -PropertyType String -Value $NewPort -Force
               	New-ItemProperty -Path $DeviceKey -Name "FriendlyName" -PropertyType String -Value $FriendlyName -Force
               
               	#Release Previous Com Port from ComDB
               	$Byte = ($OldPort - ($OldPort % 8))/8
              	$Bit = 8 - ($OldPort % 8)
             	if ($Bit -eq 8) { 
	             	$Bit = 0 
	               	$Byte = $Byte - 1
	            }
	            $ComDB = get-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\COM Name Arbiter" -Name ComDB
	            $ComBinaryArray = ([convert]::ToString($ComDB.ComDB[$Byte],2)).ToCharArray()
	            while ($ComBinaryArray.Length -ne 8) {
        	    	$ComBinaryArray = ,"0" + $ComBinaryArray
        	    }
        	    $ComBinaryArray[$Bit] = "0"
	            $ComBinary = [string]::Join("",$ComBinaryArray)
	            $ComDB.ComDB[$Byte] = [convert]::ToInt32($ComBinary,2)
                Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\COM Name Arbiter" -Name ComDB -Value ([byte[]]$ComDB.ComDB)
                }#End of COM ports
            
            #Get MidMark from SCCM
            
            
        }#End of EXM
    
    #If the device is single/MUD, restore backup, verify o365, and run Autologon
    } ELSE {

        #If backup exists, open PCMover
        IF ((Test-Path \\Backup\Path\Goes\Here\$env:computername) -eq 'True'){
            & \\PCMover\Path\Goes\Here\PCmover.exe
        }
        & \\Autologon\Tool\Goes\Here
    }
}