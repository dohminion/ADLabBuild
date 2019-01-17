import-module activedirectory

#Determine Domain info
$DomainDN = (([ADSI]"").distinguishedName[0])
$DomainDNSName = (Get-ADDomain).dnsroot

#AD Recyle Bin
Write-Output "Enabling AD Recycle Bin"
Enable-ADOptionalFeature –Identity "CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,$DomainDN" –Scope ForestOrConfigurationSet –Target $DomainDNSName

#PAM
Write-Output "Enabling PAM"
Enable-ADOptionalFeature "Privileged Access Management Feature" -Scope ForestOrConfigurationSet -Target $DomainDNSName

#LAPS
#
Write-Output "Installation of the LAPS MSI on the system from which you run this script is required before running this section.  Go install it now, and come back to this window."
Write-Output "Downlaod LAPS from here:"
write-output "https://www.microsoft.com/en-us/download/details.aspx?id=46899"
Write-Output "Press CTRL-C if you don't want to install LAPS and cancel this section of the script."


Pause
Write-Output "Enabling LAPS"
Import-Module AdmPwd.PS
Update-AdmPwdADSchema
Set-AdmPwdComputerSelfPermission -OrgUnit MemberServers
Set-AdmPwdReadPasswordPermission -OrgUnit MemberServers -AllowedPrincipals 'SEC-ServerAdmins'
Set-AdmPwdResetPasswordPermission -OrgUnit MemberServers -AllowedPrincipals 'SEC-ServerAdmins'
Set-AdmPwdComputerSelfPermission -OrgUnit ClientComputers
Set-AdmPwdReadPasswordPermission -OrgUnit ClientComputers -AllowedPrincipals 'SEC-ClientComputerAdmin'
Set-AdmPwdResetPasswordPermission -OrgUnit ClientComputers -AllowedPrincipals 'SEC-ClientComputerAdmin'
