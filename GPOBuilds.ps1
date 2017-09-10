function New-GPOBuilds
{
    #create the GPO
    new-gpo -Name $GPOName
    Start-Sleep 5
    #link GPO to policy test for review
    New-GPLink -Name $GPOName -Target $TargetOU | out-null
    #Import the GPO settings
    import-gpo -BackupGpoName $GPOName -TargetName $GPOName -path c:\GPOBaseBuilds
}

$DomainDN = (([ADSI]"").distinguishedName[0])
$TargetOU = "OU=PolicyTest,OU=PreProduction,$DomainDN"

#Build empty GPOs
$GPONames= @("GPO-DomainPasswordPolicy","GPO-LAPS","GPO-PowerShellConfig","GPO-WinServerBaseline","GPO-WS2016DCBaseline","GPO-ClientSystems")
foreach ($GPOName in $GPONames){
    Write-Output $GPOName
    New-GPOBuilds
}

#Set default users and default computers to new OUs.
#create policy for those new OUs to have warnings and blocks
#Manually link the GPOs once they have been populated, or make into a second script
