#Determine Domain info
$DomainDN = (([ADSI]"").distinguishedName[0])
Import-Module ActiveDirectory

Function New-ADOU{
    [cmdletbinding()]            
    param(            
    [string] $TestOU            
    )  
    try
    {
      if ([adsi]::Exists("LDAP://OU=$TestOU,$RootOU")){
              Write-host "$TestOU OU Exists"
      }else{
        Write-Host "OU $TestOU does not Exist"
        Write-Output 'Creating OUs'
        New-ADOrganizationalUnit -Path $RootOU -Name $TestOU -Description $TestOU
      }
    }
    catch
    {
      "Error was $_"
      $line = $_.InvocationInfo.ScriptLineNumber
      "Error was in Line $line"
    }
    
}

$RootOU =$DomainDN
New-ADOU 'ClientComputers'
New-ADOU 'MemberServers'
New-ADOU 'SecurityGroups'
New-ADOU "Groups"
New-ADOU 'PreProduction'
New-ADOU 'DefaultComputers'
New-ADOU 'DefaultUsers'

$RootOU = "OU=SecurityGroups,$DomainDN"
New-ADOU 'SecurityRoles'
New-ADOU 'PAMRoles'
New-ADOU 'PAMAccounts'

$RootOU = "OU=Groups,$DomainDN"
New-ADOU 'AccessGroups'
New-ADOU 'DistributionLists'

$RootOU = "OU=PreProduction,$DomainDN"
New-ADOU 'Policy Test'

$RootOU = "OU=MemberServers,$DomainDN"
New-ADOU "Teams"
