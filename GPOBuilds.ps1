function New-GPOBuilds
{
    #create the GPO
    new-gpo -Name $GPOName
    Start-Sleep 5
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

#NOTE - You may/will need to review the Domain Membership in the DC and Server Baselines to replace the SID with the group info from your lab


#Set default users and default computers to new OUs.
#create policy for those new OUs to have warnings and blocks
#Manually link the GPOs once they have been populated, or make into a second script
