<#
Description: This script will configure basic Windows Server settings without any input
Date: 04-06-2022
#>

Install-Module PSWindowsUpdate -confirm # Windows updates feature

# ========== Windows configurations =========
# Put empty "" to not configure it
# ===========================================
$hostname = "TEST-SERVER"

$ip_address = "192.168.20.100"
$default_gateway = "192.168.20.2"
$subnet_mask = 24
$Dns = "192.168.20.2"

$newTimeZone = "Eastern Standard Time"

$Enable_Rdp = $true # put false to stay per default

$Allow_WindowsUpdate = $true

# =========== CONFIG ===========
if($hostname -ne ""){
    Rename-Computer -NewName $hostname
}

if($ip_address -ne "" -and $default_gateway -ne "" -and $subnet_mask -ne ""){

    # Change the default netwoprk adapter settings
    $defaultAdapter = Get-NetIPAddress  | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.InterfaceAlias -match "Ethernet"}
    New-NetIPAddress -IPAddress $ip_address -DefaultGateway $default_gateway -PrefixLength $subnet_mask -InterfaceIndex $defaultAdapter.InterfaceIndex | Out-Null
}

if($Dns -ne ""){
    Set-DNSClientServerAddress -InterfaceIndex $defaultAdapter.InterfaceIndex -ServerAddresses $Dns
}

if($newTimeZone -ne ""){
    Set-TimeZone -Name $newTimeZone
}

if($Enable_Rdp){
    #Activate the firewall rule
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

    #Enable Remote Desktop
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name “fDenyTSConnections” -Value 0
}

if($Allow_WindowsUpdate){
    Get-WindowsUpdate -AcceptAll -Install -AutoReboot
}