<#
  .SYNOPSIS 
    Send a WOL packet to a broadcast address
  .PARAMETER mac
    The MAC address of the device that need to wake up
  .PARAMETER ip
    The IP address where the WOL packet will be sent to
  .EXAMPLE
    Send-WOL -mac 00:11:22:33:44:55 -ip 192.168.2.100
  .NOTES
    Use the Broadcast address *xxx.xxx.xxx.255* for remote computers?
#>

function Send-WOL {
[CmdletBinding()] param (
    [Parameter(Mandatory=$True,Position=1)]
    [string]$mac,
    [string]$ip="255.255.255.255",
    [int]$port=9
)
    $broadcast = [Net.IPAddress]::Parse($ip)
    $mac=(($mac.replace(":","")).replace("-","")).replace(".","")
    $target=0,2,4,6,8,10 | % {[convert]::ToByte($mac.substring($_,2),16)}
    $packet = (,[byte]255 * 6) + ($target * 16)
    $UDPclient = new-Object System.Net.Sockets.UdpClient
    $UDPclient.Connect($broadcast,$port)
    [void]$UDPclient.Send($packet, 102)
}

send-WOL -mac 50:9A:4C:5A:8C:B4 -ip 172.26.220.129
pause