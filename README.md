# ADLabBuild

The scripts located below are to be used to deploy an lab with a number of AD Security best practices enabled. 

The purpose of doing this would be to learn how to use PowerShell to automate all of these tasks, and take that knowledge and use it within your environments.  


I hope to be adding more options, and details over time.  

Note - the early scripts are just basic items that won't be run multiple times, and have minimal comments.  More complex scripts have more detailed information.
I will be building out additional error handling and Pester tests for all if time allows.


Prerequisites to enable all functions:
Server 2016 VM.  I used the datacenter on a Windows 10 system using Hyper-V.  Cloud based or other virtualization technologies would work fine as well.

You need the LAPS MSI installed on the system from which you run the ADEnableFeature.ps1
Get it from: https://www.microsoft.com/en-us/download/details.aspx?id=46899

For automated GPO editing, get GPAE from SDM Software.  It is well worth the modest cost compared to time saved. 
It must be installed before you run the Team Structure creation scripts. 
Trial available here:  https://sdmsoftware.com/group-policy-management-products/group-policy-automation-engine/


Here is the rough draft version I have for now.  

1.  Create a Windows Server 2016 VM.  
2.  Rename your VM to the Domain Controller name you would like, and patch it fully.
3.  Copy all files to the server.  I created and used the folder c:\Scripts
4.  On the server, run DCBuild.ps1, enter the DSRM Password you desire to be set.
Add the Admin Tools to the server:  Add-WindowsFeature RSAT-ADDS-Tools

5.  Run ADOUStructureBuild.ps1 to create the OUs for the design
6.  Run ADGroupBuilds.ps1 to create the needed security groups
7.  Optionally Run ADSitesBuild.ps1 - not required, but describes a Cloud Hybrid design for SMBs
8.  Install LAPS
9.  Run ADEnableFeatures.ps1
10.  Run GPOBuilds - Make sure the MyLabGPOBaseBuilds GPO exports have been copied to C:\Scripts\MyLabGPOBaseBuilds

 Edit the GPOs to remove SIDs and include the groups specific to your lab domain build:

 GPO-WS2016DCBaseline:
 Add workstations to domain 
 S-1-5-21-xxx-1130 - SEC-JoinComputers

NOTE - link higher than Default domain policy

WinServerBaseline:
Deny access to this computer from the network 
S-1-5-21-xxx-512 Domain Admins, 
S-1-5-21-xxx-519 Enterprise Admins, 
S-1-5-21-XXX-1133 SEC-BlockNetworkLogon 
Domain Admins;Enterprise Admins;SEC-BlockNetworkLogon

Deny log on as a batch job 
S-1-5-21-xxx-512 Domain Admins, 
S-1-5-21-xxx-519 Enterprise Admins 
Domain Admins;Enterprise Admins

Deny log on as a service 
S-1-5-21-xxx-512 Domain Admins, 
S-1-5-21-xxx-519 Enterprise Admins 
Domain Admins;Enterprise Admins

Deny log on locally 
BUILTIN\Guests, 
S-1-5-21-xxx-512 Domain Admins, 
S-1-5-21-xxx-519 Enterprise Admins, 
S-1-5-21-xxx-1117 SEC-BlockInteractiveLogon
Domain Admins;Enterprise Admins;SEC-BlockInteractiveLogon

Deny log on through Terminal Services 
BUILTIN\Guests, 
NT AUTHORITY\Local account, 
S-1-5-21-xxx-512 Domain Admins, 
S-1-5-21-xxx-519 Enterprise Admins, 
S-1-5-21-xxx-1134 SEC-BlockRDPLogon
Domain Admins;Enterprise Admins;SEC-BlockRDPLogon


ClientBaseline:
Deny access to this computer from the network 
BUILTIN\Guests, 
NT AUTHORITY\Local account, 
S-1-5-21-XXX-1133 SEC-BlockNetworkLogon 
SEC-BlockNetworkLogon

Deny log on as a batch job 
S-1-5-21-xxx-512 Domain Admins, 
S-1-5-21-xxx-519 Enterprise Admins 
Domain Admins;Enterprise Admins

Deny log on as a service 
S-1-5-21-xxx-512 Domain Admins, 
S-1-5-21-xxx-519 Enterprise Admins 
Domain Admins;Enterprise Admins

Deny log on locally 
BUILTIN\Guests, 
S-1-5-21-xxx-512 Domain Admins, 
S-1-5-21-xxx-519 Enterprise Admins, 
S-1-5-21-xxx-1117 SEC-BlockInteractiveLogon
Domain Admins;Enterprise Admins;SEC-BlockInteractiveLogon

Deny log on through Terminal Services 
BUILTIN\Guests, 
NT AUTHORITY\Local account, 
S-1-5-21-xxx-512 Domain Admins, 
S-1-5-21-xxx-519 Enterprise Admins, 
S-1-5-21-xxx-1134 SEC-BlockRDPLogon
Domain Admins;Enterprise Admins;SEC-BlockRDPLogon


11.  Install .net 3.5 (prereq for GPAE)  
Install-WindowsFeature Net-Framework-Core

12.  Install GPAE from above
13.  Run ADTeamStructureBuild - Creates a segmented OU, GPO, Groups, Admin Accounts.  GPO enforces local admins, delegation lets teams add Servers to only this OU (great for DevOps/CICD processes) without granting more permissions that absolutely required.  Each of the Admin accounts are designed to be managed by a PAM systems with single use passwords.

TODO:
- Create automated AWS or Azure VM build doc
- Include reset of default Users and Computer creation locations
- Security delegation rights to the groups created above
- Team OU structure access nesting between Forests - Will need a second VM and forest configured with working DNS.
- Support team or Shared Team Access delegation to specific OUs/servers
- Monitoring scripts
-- Group Memberships
-- Services
--- Status - Restart Failed and notify
--- Installs - Alert on new service installs
--Scheduled Tasks - Alert on Scheduled Task changes (new, modify, delete)
- Tool server build
- JEA config push
- Sysmon, and Splunk Install
- WEF config and server
- Splunk Server install
- Custom Account creation functions
- Stale computer cleanup
- Parallel patch checking
- VS Code config
- Enable Central Store
- Fine Grain Password Policies
- Convert to DSC
- Build ATA server
- Build Netwrix Freeware Server
- Links to other great articles to expand on this
- Remove adminstrator from Schema Admins


Notes:
GPO Baselines were modified from the GPOs you can download from here:
https://blogs.technet.microsoft.com/secguide/2017/08/30/security-baseline-for-windows-10-creators-update-v1703-final/

