<#
Description: This module contain function to configure easily
             basic windows server configuration
Date: 04-06-2022
#>

function set-basicConfig ($hostname, $timezone, $Enable_rdp, $WindowsUpdate){
    
    if($hostname -ne ""){
        Rename-Computer -NewName $hostname
    }

    if($timezone -ne ""){
        Set-TimeZone -Name $newTimeZone
    }
    
    if($Enable_rdp){
        #Activate the firewall rule
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

        #Enable Remote Desktop
        Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name “fDenyTSConnections” -Value 0
    }

    if($WindowsUpdate){
        Get-WindowsUpdate -AcceptAll -Install -AutoReboot
    }
}

function set-networkConfig{
    param(
        [Parameter(Mandatory)] [string] $ip_address,
        [Parameter(Mandatory)] [string] $default_gateway,
        [Parameter(Mandatory)] [string] $subnet_mask,
        [Parameter(Mandatory)] [string] $Dns
    )
    $defaultAdapter = Get-NetIPAddress  | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.InterfaceAlias -match "Ethernet"}
    New-NetIPAddress -IPAddress $ip_address -DefaultGateway $default_gateway -PrefixLength $subnet_mask -InterfaceIndex $defaultAdapter.InterfaceIndex
    Set-DNSClientServerAddress -InterfaceIndex $defaultAdapter.InterfaceIndex -ServerAddresses $Dns

}
