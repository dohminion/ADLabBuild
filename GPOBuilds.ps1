﻿function New-GPOBuilds {
    #create the GPO
    new-gpo -Name $GPOName
    #Start-Sleep 8
    #link GPO to policy test for review
    New-GPLink -Name $GPOName -Target $TargetOU | out-null
    #Import the GPO settings
    #
    #import-gpo -BackupGpoName $GPOName -TargetName $GPOName -path c:\Scripts\MyLabGPOBaseBuilds
}

Import-Module ActiveDirectory

$DomainDN = (([ADSI]"").distinguishedName[0])
$TargetOU = "OU=PolicyTest,OU=PreProduction,$DomainDN"

#Build empty GPOs
$GPONames = @("GPO-DomainPasswordPolicy", "GPO-LAPS", "GPO-PowerShellConfig", "GPO-WinServerBaseline", "GPO-WS2016DCBaseline", "GPO-ClientBaseline", "GPO-CredGuard", "GPO-Defender", "GPO-Bitlocker")
foreach ($GPOName in $GPONames) {
    Write-Output $GPOName
    New-GPOBuilds
}

#NOTE - You will need to review the Domain Membership in the DC and Server Baselines to replace the SID with the group info from your lab
.\New-GPOMigraion.ps1

Start-Sleep 8
import-gpo -BackupGpoName GPO-WS2016DCBaseline -TargetName GPO-WS2016DCBaseline -path C:\Scripts\MyLabGPOBaseBuilds\ -MigrationTable C:\Scripts\MyLabGPOBaseBuilds\MyLab.local-to-MyLab.local.migtable -ErrorAction Stop
import-gpo -BackupGpoName GPO-WinServerBaseline -TargetName GPO-WinServerBaseline -path C:\Scripts\MyLabGPOBaseBuilds\ -MigrationTable C:\Scripts\MyLabGPOBaseBuilds\MyLab.local-to-MyLab.local.migtable -ErrorAction Stop
import-gpo -BackupGpoName GPO-PowerShellConfig -TargetName GPO-PowerShellConfig -path C:\Scripts\MyLabGPOBaseBuilds\ -MigrationTable C:\Scripts\MyLabGPOBaseBuilds\MyLab.local-to-MyLab.local.migtable -ErrorAction Stop
import-gpo -BackupGpoName GPO-LAPS -TargetName GPO-LAPS -path C:\Scripts\MyLabGPOBaseBuilds\ -MigrationTable C:\Scripts\MyLabGPOBaseBuilds\MyLab.local-to-MyLab.local.migtable -ErrorAction Stop
import-gpo -BackupGpoName GPO-DomainPasswordPolicy -TargetName GPO-DomainPasswordPolicy -path C:\Scripts\MyLabGPOBaseBuilds\ -MigrationTable C:\Scripts\MyLabGPOBaseBuilds\MyLab.local-to-MyLab.local.migtable -ErrorAction Stop
import-gpo -BackupGpoName GPO-Defender -TargetName GPO-Defender -path C:\Scripts\MyLabGPOBaseBuilds\ -MigrationTable C:\Scripts\MyLabGPOBaseBuilds\MyLab.local-to-MyLab.local.migtable -ErrorAction Stop
import-gpo -BackupGpoName GPO-CredGuard -TargetName GPO-CredGuard -path C:\Scripts\MyLabGPOBaseBuilds\ -MigrationTable C:\Scripts\MyLabGPOBaseBuilds\MyLab.local-to-MyLab.local.migtable -ErrorAction Stop
import-gpo -BackupGpoName GPO-ClientBaseline -TargetName GPO-ClientBaseline -path C:\Scripts\MyLabGPOBaseBuilds\ -MigrationTable C:\Scripts\MyLabGPOBaseBuilds\MyLab.local-to-MyLab.local.migtable -ErrorAction Stop
import-gpo -BackupGpoName GPO-Bitlocker -TargetName GPO-Bitlocker -path C:\Scripts\MyLabGPOBaseBuilds\ -MigrationTable C:\Scripts\MyLabGPOBaseBuilds\MyLab.local-to-MyLab.local.migtable -ErrorAction Stop

#Link to Servers
$TargetOU = "OU=MemberServers,OU=Tier1,$DomainDN"
$GPONames = @("GPO-LAPS", "GPO-PowerShellConfig", "GPO-WinServerBaseline", "GPO-CredGuard", "GPO-Defender", "GPO-Bitlocker")
foreach ($GPOName in $GPONames) {
    Write-Output $GPOName
    New-GPLink -Name $GPOName -Target $TargetOU | out-null
}


#Link to Clients
$TargetOU = "OU=ClientComputers,OU=Tier2,$DomainDN"
$GPONames = @("GPO-LAPS", "GPO-PowerShellConfig", "GPO-ClientBaseline", "GPO-CredGuard", "GPO-Defender", "GPO-Bitlocker")
foreach ($GPOName in $GPONames) {
    Write-Output $GPOName
    New-GPLink -Name $GPOName -Target $TargetOU | out-null
}

$TargetOU = "OU=Standard Workstations,OU=Tier0,$DomainDN"
$GPONames = @("GPO-LAPS", "GPO-PowerShellConfig", "GPO-ClientBaseline", "GPO-CredGuard", "GPO-Defender", "GPO-Bitlocker")
foreach ($GPOName in $GPONames) {
    Write-Output $GPOName
    New-GPLink -Name $GPOName -Target $TargetOU | out-null
}

$TargetOU = "OU=Admin Workstations,OU=Tier0,$DomainDN"
$GPONames = @("GPO-LAPS", "GPO-PowerShellConfig", "GPO-ClientBaseline", "GPO-CredGuard", "GPO-Defender", "GPO-Bitlocker")
foreach ($GPOName in $GPONames) {
    Write-Output $GPOName
    New-GPLink -Name $GPOName -Target $TargetOU | out-null
}

#Link to DCs
$TargetOU = "OU=Domain Controllers,$DomainDN"
$GPONames = @("GPO-DomainPasswordPolicy", "GPO-PowerShellConfig", "GPO-WS2016DCBaseline", "GPO-Defender")
foreach ($GPOName in $GPONames) {
    Write-Output $GPOName
    New-GPLink -Name $GPOName -Target $TargetOU | out-null
}

#TODO
#Set default users and default computers to new OUs.
#create policy for those new OUs to have warnings and blocks
#Delegate access for groups to the OUs
