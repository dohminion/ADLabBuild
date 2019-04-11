#Basic Lab DC Build script
#Assumption - you have a Win2016 VM and run the script from within it.

install-windowsfeature AD-Domain-Services
Import-Module ADDSDeployment
Add-WindowsFeature RSAT-ADDS-Tools

#The following will default to Win2016 Domain and Functional Modes, and prompt for the DSRM password.
#The existing local administator password will become

Install-ADDSDomainController -InstallDns `
-Credential (Get-Credential) `
-DomainName "mylab.local" `
-DatabasePath "C:\Windows\NTDS" `
-LogPath "C:\Windows\NTDS" `
-SysvolPath "C:\Windows\SYSVOL" `
-NoRebootOnCompletion:$false `
-Force:$true
