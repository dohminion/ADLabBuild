# ADLabBuild

The scripts located below are to be used to deploy an lab with a number of AD Security best practices enabled. 

The purpose of doing this would be to learn how to use PowerShell to automate all of these tasks, and take that knowledge and use it within your environments.  This also creates a more secure AD build that can be used for more challening pen testing.


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
5.  Run ADOUStructureBuild.ps1 to create the OUs for the design
6.  Run ADGroupBuilds.ps1 to create the needed security groups
7.  Optionally Run ADSitesBuild.ps1 - not required, but describes a Cloud Hybrid design for SMBs
8.  Run ADEnableFeatures.ps1



TODO:
- Create automated Azure VM build doc
- Include reset of default Users and Computer creation locations
- Security delegation rights to the groups created above
- GPO build scripts - Import from baseline templates
- Team OU structure builds including delegated access, and GPOs
- Team OU structure access nesting between Forests - Will need a second VM and forest configured with working DNS.
- Support/Shared Team Access delegation
- Links for LAPS download
- Links for baseline GPO Downloads
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

- CA Config?

Notes:
Win10 GPO Baseline from:
https://blogs.technet.microsoft.com/secguide/2017/08/30/security-baseline-for-windows-10-creators-update-v1703-final/

