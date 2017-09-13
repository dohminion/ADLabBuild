function New-GPOBuilds
{
    #create the GPO
    new-gpo -Name $GPOName
    Start-Sleep 8
    #link GPO to policy test for review
    New-GPLink -Name $GPOName -Target $TargetOU | out-null
    #Import the GPO settings
    import-gpo -BackupGpoName $GPOName -TargetName $GPOName -path c:\Scripts\MyLabGPOBaseBuilds
}

Import-Module ActiveDirectory

$DomainDN = (([ADSI]"").distinguishedName[0])
$TargetOU = "OU=PolicyTest,OU=PreProduction,$DomainDN"

#Build empty GPOs
$GPONames= @("GPO-DomainPasswordPolicy","GPO-LAPS","GPO-PowerShellConfig","GPO-WinServerBaseline","GPO-WS2016DCBaseline","GPO-ClientBaseline","GPO-CredGuard","GPO-Defender","GPO-Bitlocker")
foreach ($GPOName in $GPONames){
    Write-Output $GPOName
    New-GPOBuilds
}

#NOTE - You will need to review the Domain Membership in the DC and Server Baselines to replace the SID with the group info from your lab


Write-Output "You will need to modify the imported policies to remove (just!) the SIDs and replace them with the following:"
Write-Output ""
Write-Output "---GPO-WS2016DCBaseline:---"
Write-Output "Add workstations to domain" 
Write-Output "SEC-JoinComputers"
Write-Output ""
Write-Output ""
Write-Output "---WinServerBaseline:---"
Write-Output "Deny access to this computer from the network"
Write-Output "Domain Admins;Enterprise Admins;SEC-BlockNetworkLogon"
Write-Output ""
Write-Output "Deny log on as a batch job"
Write-Output "Domain Admins;Enterprise Admins"
Write-Output ""
Write-Output "Deny log on as a service"
Write-Output "Domain Admins;Enterprise Admins"
Write-Output ""
Write-Output "Deny log on locally "
Write-Output "Domain Admins;Enterprise Admins;SEC-BlockInteractiveLogon"
Write-Output ""
Write-Output "Deny log on through Terminal Services"
Write-Output "Domain Admins;Enterprise Admins;SEC-BlockRDPLogon"
Write-Output ""
Write-Output ""
Write-Output "---ClientBaseline:---"
Write-Output "Deny access to this computer from the network "
Write-Output "SEC-BlockNetworkLogon"
Write-Output ""
Write-Output "Deny log on as a batch job "
Write-Output "Domain Admins;Enterprise Admins"
Write-Output ""
Write-Output "Deny log on as a service "
Write-Output "Domain Admins;Enterprise Admins"
Write-Output ""
Write-Output "Deny log on locally "
Write-Output "Domain Admins;Enterprise Admins;SEC-BlockInteractiveLogon"
Write-Output ""
Write-Output "Deny log on through Terminal Services "
Write-Output "Domain Admins;Enterprise Admins;SEC-BlockRDPLogon"
Write-Output ""
 

Write-Output 'Review the GPOs and edit appropriately before continuing to link GPOs to the MemberServers OU.'

pause


#Link to Servers
$TargetOU = "OU=MemberServers,$DomainDN"
$GPONames= @("GPO-LAPS","GPO-PowerShellConfig","GPO-WinServerBaseline","GPO-CredGuard","GPO-Defender","GPO-Bitlocker")
foreach ($GPOName in $GPONames){
    Write-Output $GPOName
    New-GPLink -Name $GPOName -Target $TargetOU | out-null
}


Write-Output 'Review the GPOs and edit appropriately before continuing to link GPOs to the ClientComputers OU.'
pause

#Link to Clients
$TargetOU = "OU=ClientComputers,$DomainDN"
$GPONames= @("GPO-LAPS","GPO-PowerShellConfig","GPO-ClientBaseline","GPO-CredGuard","GPO-Defender","GPO-Bitlocker")
foreach ($GPOName in $GPONames){
    Write-Output $GPOName
    New-GPLink -Name $GPOName -Target $TargetOU | out-null
}

Write-Output 'Review the GPOs and edit appropriately before continuing to link GPOs to the DomainControllers OU.'
pause


#Link to DCs
$TargetOU = "OU=Domain Controllers,$DomainDN"
$GPONames= @("GPO-DomainPasswordPolicy","GPO-PowerShellConfig","GPO-WS2016DCBaseline","GPO-Defender")
foreach ($GPOName in $GPONames){
    Write-Output $GPOName
    New-GPLink -Name $GPOName -Target $TargetOU | out-null
}


#Set default users and default computers to new OUs.
#create policy for those new OUs to have warnings and blocks

