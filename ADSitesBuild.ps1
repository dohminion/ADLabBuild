Import-Module ActiveDirectory

#Build Sites
Write-Output 'Creating Sites'
New-ADReplicationSite -name Azure-East
New-ADReplicationSite -name Azure-West
New-ADReplicationSite -name Local-WestDataCenter
New-ADReplicationSite -name Local-EastDataCenter
New-ADReplicationSite -name Local-WestRegional
New-ADReplicationSite -name Local-EastRegional
New-ADReplicationSite -name Local-NorthRegional
New-ADReplicationSite -name Local-SouthRegional
New-ADReplicationSite -name DCDecom
New-ADReplicationSite -name WANLink
New-ADReplicationSite -name CloudLink
Write-Output 'Waiting 10 seconds to make sure the Sites are available for linking. Not really needed in a lab, but required in a larger environment'
Start-Sleep 10

#Create SiteLinks
#Core
Write-Output 'Creating Core Site Links'
New-ADReplicationSiteLink -Name 'WANLink --> Local-WestDataCenter' -SitesIncluded WANLink,Local-WestDataCenter -Cost 100 -ReplicationFrequencyInMinutes 15 -InterSiteTransportProtocol IP -OtherAttributes @{'options'=1}
New-ADReplicationSiteLink -Name 'WANLink --> Local-EastDataCenter ' -SitesIncluded WANLink,Local-EastDataCenter -Cost 100 -ReplicationFrequencyInMinutes 15 -InterSiteTransportProtocol IP -OtherAttributes @{'options'=1}
New-ADReplicationSiteLink -Name 'WANLink --> CloudLink' -SitesIncluded WANLink,CloudLink -Cost 200 -ReplicationFrequencyInMinutes 15 -InterSiteTransportProtocol IP -OtherAttributes @{'options'=1}
New-ADReplicationSiteLink -Name 'ClouldLink --> Azure-West' -SitesIncluded CloudLink,Azure-West -Cost 100 -ReplicationFrequencyInMinutes 15 -InterSiteTransportProtocol IP -OtherAttributes @{'options'=1}
New-ADReplicationSiteLink -Name 'CloudLink --> Azure-East' -SitesIncluded CloudLink,Azure-East -Cost 100 -ReplicationFrequencyInMinutes 15 -InterSiteTransportProtocol IP -OtherAttributes @{'options'=1}
New-ADReplicationSiteLink -Name 'WANLink --> DCDecom' -SitesIncluded WANLink,DCDecom -Cost 2000 -ReplicationFrequencyInMinutes 15 -InterSiteTransportProtocol IP

#regional
Write-Output 'Creating Regional Site Links'
New-ADReplicationSiteLink -Name 'WANLink --> Local-WestRegional' -SitesIncluded WANLink,Local-WestRegional -Cost 500 -ReplicationFrequencyInMinutes 15 -InterSiteTransportProtocol IP
New-ADReplicationSiteLink -Name 'WANLink --> Local-EastRegional' -SitesIncluded WANLink,Local-EastRegional -Cost 500 -ReplicationFrequencyInMinutes 15 -InterSiteTransportProtocol IP
New-ADReplicationSiteLink -Name 'WANLink --> Local-NorthRegional' -SitesIncluded WANLink,Local-NorthRegional -Cost 500 -ReplicationFrequencyInMinutes 15 -InterSiteTransportProtocol IP
New-ADReplicationSiteLink -Name 'WANLink --> Local-SouthRegional' -SitesIncluded WANLink,Local-SouthRegional -Cost 500 -ReplicationFrequencyInMinutes 15 -InterSiteTransportProtocol IP

Write-Output 'Modify CSVs with IP info relevant to your lab then remove the comments below to import the Subnet information to make use of these sites'
#Import the IP Subnets from CSV files as shown in the following examples
#import-csv c:\scripts\Supersubnets.csv | New-ADReplicationSubnet -Verbose
#import-csv C:\Scripts\subnetList1.csv | New-ADReplicationSubnet -Verbose
#import-csv c:\scripts\subnetList2.csv | New-ADReplicationSubnet -Verbose

#CSV files should be configure with column headers of Name,Site
#The values for Name is the CIDR network
#The vaules for Site would be for Site name in double quotes.  

#For Example:
#10.0.0.0/8,"CN=Local-WestDataCenter,CN=Sites,CN=Configuration,DC=MyLabl,DC=Local"
#10.1.0.0/16,"CN=Local-WestRegional,CN=Sites,CN=Configuration,DC=MyLabl,DC=Local"
#10.2.0.0/16,"CN=Local-EastDataCenter,CN=Sites,CN=Configuration,DC=MyLabl,DC=Local"

