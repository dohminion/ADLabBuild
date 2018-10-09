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
New-ADOU 'Tier0'
New-ADOU 'Tier1'
New-ADOU 'Tier2'
New-ADOU 'Groups'
New-ADOU 'PreProduction'
New-ADOU 'DefaultComputers'
New-ADOU 'DefaultUsers'
New-ADOU 'Accounts'

$RootOU = "OU=Tier0,$DomainDN"
New-ADOU 'SecurityGroups'
New-ADOU 'Tool Servers'
New-ADOU 'Admin Accounts'
New-ADOU 'Admin Workstations'
New-ADOU 'Standard Accounts'
New-ADOU 'Standard Workstations'

$RootOU = "OU=SecurityGroups,OU=Tier0,$DomainDN"
New-ADOU 'SecurityTeams'
New-ADOU 'PAMRoles'
New-ADOU 'PAMAccounts'

$RootOU = "OU=Tier1,$DomainDN"
New-ADOU 'MemberServers'
New-ADOU 'Admin Accounts'
New-ADOU 'Admin Workstations'

$RootOU = "OU=MemberServers,OU=Tier1,$DomainDN "
New-ADOU 'Teams'

$RootOU = "OU=Tier2,$DomainDN"
New-ADOU 'ClientComputers'
New-ADOU 'Admin Accounts'
New-ADOU 'Admin Workstations'

$RootOU = "OU=Groups,$DomainDN"
New-ADOU 'AccessGroups'
New-ADOU 'DistributionLists'

$RootOU = "OU=PreProduction,$DomainDN"
New-ADOU 'PolicyTest'


$RootOU = "OU=Accounts,$DomainDN"
New-ADOU 'Standard Users'
New-ADOU 'Service Accounts'

