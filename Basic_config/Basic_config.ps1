<#
Description: This script will configure basic Windows Server settings
Date: 28-05-2022
#>

#Prevent cmdlet to display any error or warning on the client terminal
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"

Install-Module PSWindowsUpdate -confirm # Windows updates feature


Write-Host "****************************************************"
Write-Host "******** BASIC WINDOWS SERVER CONFIGURATION ********"
Write-Host "****************************************************"


#********************** HOSTNAME **********************
do {
    $hostname = Read-Host -prompt "Enter your server hostname"

    try {
        
        #hostname cannot go over 15 bytes 
        if ($hostname.Length -ge 15) {
            throw [System.IO.InvalidDataException]::new()
        }
        
        Rename-Computer -NewName $hostname
        
        #Display the error on the screen if it has one
        if($? -eq $false){
            throw (Get-Error -Newest 1).Exception.Message
        }

        Write-Host "Hostname : Done" -ForegroundColor Green
        
    }catch [System.IO.InvalidDataException] {
        Write-Error "hostname cannot have more than 15 characters"
    }
    catch {
        Write-Error $_.Exception.Message
    }

} until (
    $? -eq $true #Last operation doesn't have any error 
)

#********************** NETWORK CONFIG **********************

do {
    #Get network information for the interface
    $ip_address = Read-Host -prompt "Static IP address"
    $subnet_mask = Read-Host -prompt "Subnet mask prefix [2 - 30] (default is 24)"
    $default_gateway = Read-Host -Prompt "Default Gateway"
    $Dns = Read-Host -Prompt "Dns server"
    
    if ($subnet_mask -eq ""){
        $subnet_mask = "24"
    }
    try {
        
        #Change default adapter settings
        $defaultAdapter = Get-NetIPAddress  | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.InterfaceAlias -match "Ethernet"}
        New-NetIPAddress -IPAddress $ip_address -DefaultGateway $default_gateway -PrefixLength $subnet_mask -InterfaceIndex $defaultAdapter.InterfaceIndex | Out-Null
        Set-DNSClientServerAddress -InterfaceIndex $defaultAdapter.InterfaceIndex -ServerAddresses $Dns
        
        #Display the error on the screen if it has one
        if($? -eq $false){
            throw (Get-Error -Newest 1).Exception.Message
        }

        Write-Host "Network config : Done" -ForegroundColor Green
    }
    catch {
        Write-Error $_.Exception.Message
    }

} until (
    $? -eq $true #Last operation doesn't have any error 
)

#********************** TIMEZONE **********************
Write-Host "Timezone is presently: " (get-timezone).DisplayName
$change_timezone = Read-Host -prompt "Do you want to change it ? (y/n)"

if( $change_timezone -eq 'y'){
    do {
        $newTimeZone = Read-Host -prompt "Your new timezone (default: Eastern Standard Time)"
        
        if($newTimeZone -eq ""){
            $newTimeZone = "Eastern Standard Time"
        }
        
        try {
            Set-TimeZone -Name $newTimeZone
                
            #Display the error on the screen if it has one
            if($? -eq $false){
                throw (Get-Error -Newest 1).Exception.Message
            }
            Write-Host "TimeZone : Done" -ForegroundColor Green
        }
        catch {
            Write-Error $_Exception.Message
        }
        
    } until (
        $? -eq $true #Last operation doesn't have any error 
    )
}else{
    Write-Host "Timezone : unchanged" -ForegroundColor DarkRed
}

#********************** ENABLE RDP **********************
$Remote_Desktop = Read-Host -prompt "Allow Remote Desktop? (y/n)"

if($Remote_Desktop -eq "y"){
    
    #Activate the firewall rule
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

    #Enable Remote Desktop
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name “fDenyTSConnections” -Value 0
    
    Write-Host "Remote Desktop : Done" -ForegroundColor Green
}else{
    Write-Host "Remote Desktop is disabled" -ForegroundColor DarkRed
}

#********************** WINDOWS UPDATE **********************

Write-Host "Windows update in progress... The server will restart and will be ready to use" -ForegroundColor Blue
Get-WindowsUpdate -AcceptAll -Install -AutoReboot
Write-Host "Windows Update : Done" -ForegroundColor Green

