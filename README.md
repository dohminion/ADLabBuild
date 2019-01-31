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

1.  Create a Windows Server 2016 VM (Preferably using your favorite automation solution).  
2.  Install all available Patches!
3.  Copy all files to the server.  I created and used the folder c:\Scripts.  Please us this if you don't want to modify the files.


4.  CD to c:\Scripts and Run 1-DCBuild.ps1, enter the DSRM Password you desire to be set. The server will reboot.  
Note - You will get warnings if using DHCP, and about DNS resolution.  This is normal.  You will also need to change the admin password after first logon to the domain.

5.  Run 2-RunStructureBuild.ps1
NOTE - You will need to change the link order of the new GPOs higher than Default domain policy.


You will now have an AD structure with Groups, OUs, and GPOs, designed to match MS Best practices, and Tier Design to help prevent PTH.




To see a design that adds additional lateral movement segmentation, continue with the following:

6.  Install .net 3.5 (prereq for GPAE)  
Install-WindowsFeature Net-Framework-Core

7.  Install GPAE from above
8.  Run ADTeamStructureBuild - Creates segmented OUs, GPOs, Groups, and Admin Accounts.  
GPO enforces local admins.  Delegation is configured to let teams add Servers to only this OU (great for DevOps/CICD processes) without granting more permissions than absolutely required.  Each of the Admin accounts are designed to be managed by a PAM system with single use passwords.




TODO:

- Include reset of default Users and Computer creation locations
- Security delegation rights to the groups created above
- Monitoring scripts
- Group Memberships
- Installs - Alert on new service installs
- Scheduled Tasks - Alert on Scheduled Task changes (new, modify, delete)
- Tool server build
- JEA config push
- Stale computer cleanup
- 
- Enable Central Store
- Fine Grain Password Policies
- Convert to DSC
- Links to other great articles to expand on this
- Remove adminstrator from Schema Admins


Notes:
GPO Baselines were modified from the GPOs you can download from here:
https://blogs.technet.microsoft.com/secguide/2017/08/30/security-baseline-for-windows-10-creators-update-v1703-final/

