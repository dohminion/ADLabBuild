#Requires -Version 4.0
 param (
    $UserCount ='empty',
    $teamNumber = $null
 )
 #Set-StrictMode -version latest

$inputOK = $false
do
    {
    [string]$teamNumber = Read-host 'Enter the 5 digit Service Number:' 
   if ($teamNumber -match '^\d{5}$'){
        $inputOK =$true
        }
    else
        {
    Write-output "INVALID INPUT!  You must enter a 5 digit numeric value"
    }
}
until ($inputOK)

#______________________________________________
#Import required modules
Import-Module activedirectory
Import-Module GroupPolicy
Add-Type -AssemblyName System.Web

#Determine Domain info
$DomainDN = (([ADSI]"").distinguishedName[0])
$UPNS=$DomainDN -replace ",DC=", "."
$UPNSuffix =$UPNS -replace "DC=", "@"
$DomainDNSName = (Get-ADDomain).dnsroot
$nbn=(get-addomain).netbiosname

#Create the TeamOU 
Write-Output "Creating OUs"
$RootOU = "OU=Teams,OU=MemberServers,$DomainDN"
	New-ADOrganizationalUnit -Path $RootOU -Name "T$teamNumber" -Description "TEAM $teamNumber"
 
#______________________________________________
#Set OUs 
$SECROLEOU = "OU=SecurityTeams,OU=SecurityGroups,$DomainDN"
$SECACCOU = "OU=AccessGroups,OU=Groups,$DomainDN"
$DISTOU = "OU=DistributionLists,OU=Groups,$DomainDN"
$PAMOU = "OU=PAMRoles,OU=SecurityGroups,$DomainDN"
$USEROU = "OU=PAMAccounts,OU=SecurityGroups,$DomainDN"

#______________________________________________
#Create Group names 
$SECADMGRP = "SEC-T$teamNumber Admins"
$SECACCGRP = "SEC-T$teamNumber Standard"
$SECROGRP = "SEC-T$teamNumber ReadOnly"

#______________________________________________
#Create Prod groups.
Write-Output "Creating Groups"
New-ADGroup -name $SECADMGRP -GroupCategory 'Security' -GroupScope 'DomainLocal' -samAccountName $SECADMGRP -Description "Admin accounts for TEAM $teamNumber systems" -Path $SECROLEOU
New-ADGroup -name $SECACCGRP -GroupCategory 'Security' -GroupScope 'DomainLocal' -samAccountName $SECACCGRP -Description "Regular user accounts for TEAM $teamNumber"  -Path $SECACCOU
New-ADGroup -name $SECROGRP -GroupCategory 'Security' -GroupScope 'DomainLocal' -samAccountName $SECROGRP -Description "Read Only Access accounts for TEAM $teamNumber"  -Path $SECACCOU
Start-Sleep 5

#______________________________________________
#Create the PROD admin accounts
[int]$UserCount = 0
if ($UserCount -eq 0){
$UserCount = $null
[int]$UserCount = Read-Host 'Enter the number of ADMIN accounts to create (2 is suggested) '
}
$UserCount++

#______________________________________________
Write-Output "Creating admin accounts"
For ($i=1; $i -lt $UserCount; $i++)  {
#Write-Host $i

#Create the admin accounts
$Acct1 = "ADMIN-T$teamNumber-$i"
$UPN1 =$Acct1+$UPNSuffix
$EmployeeType="ADMIN"


#Gen the password
$PW=[System.Web.Security.Membership]::GeneratePassword(15,3)
$SecPassword =(ConvertTo-SecureString –AsPlaintext $PW –Force)
New-ADUser -Name $Acct1 -Path $UserOU -samAccountName $Acct1 -DisplayName $Acct1 -userPrincipalName $UPN1 -Description "ADMIN account for TEAM $teamNumber" -AccountPassword $SecPassword -Enabled $true
#Need to pause here to prevent errors
Start-Sleep 8
Get-ADUser $Acct1 -Properties * | Set-ADUser -Replace @{employeeType=$employeeType}

#add the admin accounts to the ADMIN group
Add-ADGroupMember $SECADMGRP $Acct1
}

#______________________________________________
Write-Output "Creating GPOs"
#Create new GPO, and link it to the team OU
$GPOName = "GPO-TEAM-"+$teamNumber
$TargetOU = “OU=T$teamNumber,”+$RootOU
New-GPO  -Name $GPOName
New-GPLink -Name $GPOName -Target $TargetOU | out-null

#Need to pause here to prevent errors
Start-Sleep 5

#______________________________________________
#Add the ADMIN Group to the GPO
import-module SDM-GroupPolicy
#import-module SDM-GPAEScript

$gpo = get-sdmgpobject -gpoName "gpo://$DomainDNSName/$GPOName" -openbyName
$container = $gpo.GetObject("Computer Configuration/Windows Settings/Security Settings/Restricted Groups");
$setting = $container.Settings.AddNew("Administrators") #This will wipe existing members, or add the group if it doesn't exist in the policy
$setting = $container.Settings.ItemByName(“Administrators”)
$members = [System.Collections.ArrayList]$setting.GetEx("Members")
$members.Add("$nbn\$SECADMGRP")
$setting.PutEx([GPOSDK.PropOp]"PROPERTY_UPDATE", "Members", $members)
$setting.Save()

#______________________________________________
#Need to pause here to prevent errors
Start-Sleep 5
Write-Output "Set OU protect from accidental deletion flag."
#set OU protection so they can't be deleted
$SearchBase = “OU=T$teamNumber,”+$RootOU
Get-ADOrganizationalUnit -filter * -SearchBase $SearchBase | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $true

#grant the ADMIN group the ability to add/remove computers from this OU only
$GrantCMD = "dsacls $SearchBase /I:T /G ""$nbn\$SECADMGRP"":CCDC;computer"
cmd.exe /C $GrantCMD
$GrantCMD = "dsacls $SearchBase /I:S /G ""$nbn\$SECADMGRP"":SDDTWO;;computer"cmd.exe /C $GrantCMD$GrantCMD = "dsacls $SearchBase /I:S /G ""$nbn\$SECADMGRP"":WP;userAccountControl;computer"
cmd.exe /C $GrantCMD
