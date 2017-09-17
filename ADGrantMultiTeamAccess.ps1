#Requires -Version 4.0
$UserCount ='empty'
$teamNumber = $null
$delegateTeam = $null
Set-StrictMode -version latest
#______________________________________________
#Get basic Domain info and setup
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
#______________________________________________
#Set OUs and names for the related Groups
$SecOU = "OU=SecurityTeams,OU=SecurityGroups,$DomainDN"
$UserOU = "OU=PAMAccounts,OU=SecurityGroups,$DomainDN"

Function Get-TEAMInfo{
    [CmdletBinding()]
    param
        (
        [parameter (Mandatory,ValueFromPipeline)]
        [Validatepattern('^\d{5}$')]
        [string]$teamNumber
        ,
        [parameter (Mandatory,ValueFromPipeline)]
        [Validatepattern('^\d{5}$')]
        [string]$delegateTeam
        )
    Write-Output "The target TEAM is $teamNumber, creating shared structure for access for Team $delegateTeam"
    New-OUBuilds
}


Function New-OUBuilds{
    #______________________________________________
    #Create the OU (The target team must already exist)
    #Example of using different OU structures for different domains
    Write-Output "Creating OUs"
    #if ($nbn -eq "SpecialDEV")
    #{
    #    $RootOU = "OU=$teamNumber,OU=SpecialTeams,OU=MemberServers,$DomainDN"
    #}
    #else
    #{
        $RootOU = "OU=T$teamNumber,OU=Teams,OU=MemberServers,$DomainDN"
    #}
    New-ADOrganizationalUnit -Path $RootOU -Name "T$teamNumber-T$delegateTeam" -Description "TEAM T$delegateTeam sub-OU access in TEAM T$teamNumber"
    #______________________________________________
    #Need to pause here to prevent errors
    Start-Sleep 5
    Write-Output "Set OU protect from accidental deletion flag."
    #set OU protection so they can't be deleted
    $SearchBase = $RootOU
    Get-ADOrganizationalUnit -filter * -SearchBase $SearchBase | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $true
    New-GroupBuilds
}

Function New-GroupBuilds{
    #______________________________________________
    # Group names DEV,Cert,Prod
    $ComboAdminName = "SEC-T$delegateTeam-T$teamNumber Admins"
    #______________________________________________
    #Create group.
    #Example of using different group types to allow for nesting across forests
    Write-Output "Creating Group..."
    if ($nbn.ToUpper() -eq 'ROOT')
    {
        New-ADGroup -name $ComboAdminName -GroupCategory 'Security' -GroupScope 'Global' -samAccountName $ComboAdminName -Description "Admin Access for TEAM $delegateTeam to TEAM $teamNumber systems" -Path $SecOU
    }
    else
    {
       New-ADGroup -name $ComboAdminName -GroupCategory 'Security' -GroupScope 'DomainLocal' -samAccountName $ComboAdminName -Description "Admin Access for TEAM $delegateTeam to TEAM $teamNumber systems" -Path $SecOU
    }
    New-AccountBuilds
}

Function New-AccountBuilds{
    #______________________________________________
    #Create the ADMIN accounts
    #$UserCount = $null
    if ($UserCount -eq 'empty'){
        $UserCount = $null
        [int]$UserCount = Read-Host 'Enter the number of ADMIN accounts to create: '
        }
    $UserCount++
    
    #______________________________________________
    Write-Output "Creating ADMIN accounts"
    For ($i=1; $i -lt $UserCount; $i++)  {
        #Info to Create the ADMIN accounts
        $Acct1 = "ADMIN-T$delegateTeam-$teamNumber-$i"
        $UPN1 =$Acct1+$UPNSuffix
        $EmployeeType="ADMIN"
        #Gen the password
        $PW=[System.Web.Security.Membership]::GeneratePassword(15,3)
        #$PW | Get-Phonetic >"c:\scripts\$acct1.txt"
        $SecPassword =(ConvertTo-SecureString -AsPlainText $PW -Force)
        #Create the ADMIN accounts
        New-ADUser -Name $Acct1 -Path $UserOU -samAccountName $Acct1 -DisplayName $Acct1 -userPrincipalName $UPN1 -Description "PAM Managed account for TEAM $teamNumber" -AccountPassword $SecPassword -Enabled $true
        #Need to pause here to prevent errors
        Start-Sleep 10
        Get-ADUser $Acct1 -Properties * | Set-ADUser -Replace @{employeeType=$employeeType}
        #add the ADMIN accounts to the SEC group
        Add-ADGroupMember $ComboAdminName $Acct1
    }
    New-GPOBuilds
}

Function New-GPOBuilds{
    #______________________________________________
    Write-Output "Creating GPOs"
    #Create new GPO, and link it to the team OU
    $GPOName = "GPO-TEAM-$teamNumber-$delegateTeam"
    $TargetOU = "OU=T$teamNumber-T$delegateTeam,"+$RootOU
    New-GPO -Name $GPOName
    #Need to pause here to prevent errors
    Start-Sleep 8
    New-GPLink -Name $GPOName -Target $TargetOU | out-null
    New-GPOSettings
}

Function New-GPOSettings{    
    #______________________________________________
    #Add the SEC Group to the GPO
    import-module SDM-GroupPolicy
    
    $gpo = get-sdmgpobject -gpoName "gpo://$DomainDNSName/$GPOName" -openbyName
    $container = $gpo.GetObject("Computer Configuration/Windows Settings/Security Settings/Restricted Groups");
    $container
    $containerReady = $false
    do
        {
           if ($container){
            $containerReady =$true
            }
        else
            {
        Write-output "container not ready, sleeping..."
        Start-Sleep 5
        }
    }
    until ($containerReady)
    $setting = $container.Settings.AddNew("Administrators") #This will wipe existing members, or add the group if it doesn't exist in the policy
    $setting = $container.Settings.ItemByName("Administrators")
    $members = [System.Collections.ArrayList]$setting.GetEx("Members")
    $members.Add("$nbn\$ComboAdminName")
    $members.Add("$nbn\SEC-$teamNumber Admins")
    $setting.PutEx([GPOSDK.PropOp]"PROPERTY_UPDATE", "Members", $members)
    $setting.Save()

    New-AccessDelegation
}

function New-AccessDelegation
{
        $Delegationbase = "OU=T$teamNumber-T$delegateTeam,OU=T$teamNumber,OU=Teams,OU=MemberServers,$DomainDN"
        Write-Output "Delegating Computer Management to $Delegationbase"
        #delegate access
        $GrantCMD = "dsacls $Delegationbase /I:T /G ""$nbn\$ComboAdminName"":CCDC;computer"
        cmd.exe /C $GrantCMD
        $GrantCMD = "dsacls $Delegationbase /I:S /G ""$nbn\$ComboAdminName"":SDDTWO;;computer"
        cmd.exe /C $GrantCMD
        $GrantCMD = "dsacls $Delegationbase /I:S /G ""$nbn\$ComboAdminName"":WP;userAccountControl;computer"
        cmd.exe /C $GrantCMD
}

Write-Output "Enter the target TEAM for teamNumber, and enter the second TEAM to share access to some systems for the EelegateTeam"
Get-TEAMInfo
