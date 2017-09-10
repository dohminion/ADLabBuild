Import-Module ActiveDirectory

function New-GroupBuild{
New-ADGroup -name $SecGroupName -GroupCategory 'Security' -GroupScope 'DomainLocal' -samAccountName $SecGroupName -Path $SecOU
}

#Determine Domain info
$DomainDN = (([ADSI]"").distinguishedName[0])
$SecOU = "OU=SecurityGroups,$DomainDN"

$SecGroupNames= @("SEC-BlockInteractiveLogon","SEC-BLockNetworkLogon","SEC-BlockRDPLogon","SEC-ServiceAccounts","SEC-JEADCOps","SEC-ComputerAccountAdmins","SEC-UserAdmins","SEC-UserModify","SEC-GroupAdmins","SEC-GroupModify","SEC-PWResetClearLockouts","SEC-ServerAdmins","SEC-ClientComputerAdmin","SEC-IAMAdmins","SEC-IAMLogon","SEC-JoinComputers","SEC-SQLServerAdmins","SEC-PAM-SDHolder")
foreach ($SecGroupName in $SecGroupNames){
    Write-Output $SecGroupName
    New-GroupBuild
}

#Run the following later in an Admin CMD shell if required
#The following can be used as one way to delegate password management to Domain Admin level accounts, from an account that itself is not a Domain Admin
#This group, and any accounts in it, must be secured in the same manner as a direct member of the Domain Admins group.
#dsacls "CN=AdminSDHolder,CN=System,DC=MyLab,DC=local" /G "\SEC-PAM - SDHolder":CA;"Reset Password"
#dsacls "CN=AdminSDHolder,CN=System,DC=MyLab,DC=local" /G "\SEC-PAM - SDHolder":RPWP;pwdLastSet
