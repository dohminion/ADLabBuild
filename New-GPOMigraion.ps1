#TODO - Combine this function with the other script to create and populate the GPOs in one step
Function New-GPOMigrationTable {
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $DestDomain,
        #[Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $Path = 'C:\Scripts\MyLabGPOBaseBuilds', # Working path to store migration tables and backups
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $BackupPath,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [String]
        $MigTableCSVPath
    )
            # Instead of manually editing multiple migration tables,
            # use a CSV template of search/replace values to update the
            # migration table by code.
            $MigTableCSV = Import-CSV $MigTableCSVPath
            $MigDomains  = $MigTableCSV | Where-Object {$_.Type -eq "Domain"}
            $MigUNCs     = $MigTableCSV | Where-Object {$_.Type -eq "UNC"}
     
            # Code adapted from GPMC VBScripts
            # This version uses a GPO backup to get the migration table data.
     
            $BackupDirectory = 'C:\Scripts\MyLabGPOBaseBuilds'
            $gpm = New-Object -ComObject GPMgmt.GPM
            $MigrationTable = $gpm.CreateMigrationTable()
            $Constants = $gpm.getConstants()
            $GPMBackupDir = $gpm.GetBackupDir($BackupDirectory)
            $GPMSearchCriteria = $gpm.CreateSearchCriteria()
            $BackupList = $GPMBackupDir.SearchBackups($GPMSearchCriteria)
     
            ForEach ($GPMBackup in $BackupList) {
                write-host $GPMBackup.GPODisplayName
                [string]$GPOName = $GPMBackup.GPODisplayName
                #"new-gpo -Name '$GPOName'"| Out-File C:\Scripts\CreateAll.ps1 -Append
                #"import-gpo -BackupGpoName $GPOName -TargetName $GPOName -path $BackupPath -MigrationTable $migTable -ErrorAction Stop" | Out-File C:\Scripts\RunAll.ps1 -Append
    
    
                $BackupDomain = $GPMBackup.GPODomain
                $MigrationTable.Add(0,$GPMBackup)
                $MigrationTable.Add($constants.ProcessSecurity,$GPMBackup)
                $SourceDomain = $GPMBackup.GPODomain
            }
     
            $SourceDomain = $GPMBackup.GPODomain
     
            ForEach ($Entry in $MigrationTable.GetEntries()) {
     
                Switch ($Entry.EntryType) {
                    
                    # Search/replace UNC paths from CSV file
                    $Constants.EntryTypeUNCPath {
                        ForEach ($MigUNC in $MigUNCs) {
                            If ($Entry.Source -like "$($MigUNC.Source)*") {
                                $MigrationTable.UpdateDestination($Entry.Source, $Entry.Source.Replace("$($MigUNC.Source)","$($MigUNC.Destination)")) | Out-Null
                            }
                        }
                    }
     
                    # Search/replace domain names from CSV file
                    # v3 {$_ -in $Constants.EntryTypeLocalGroup, $Constants.EntryTypeGlobalGroup, $Constants.EntryTypeUnknown} {
                    # 2018_10_01 - Jeremy Palenchar - Added Local Groups
                    {$Constants.EntryTypeUser, $Constants.EntryTypeGlobalGroup, $Constants.EntryTypeUnknown, $Constants.EntryTypeLocalGroup -contains $_} {
                        ForEach ($MigDomain in $MigDomains) {
                            If ($Entry.Source -like "*@$($MigDomain.Source)") {
                                $MigrationTable.UpdateDestination($Entry.Source, $Entry.Source.Replace("@$($MigDomain.Source)","@$($MigDomain.Destination)")) | Out-Null
                            } ElseIf ($Entry.Source -like "$($MigDomain.Source)\*") {
                                $MigrationTable.UpdateDestination($Entry.Source, $Entry.Source.Replace("$($MigDomain.Source)\","$($MigDomain.Destination)\")) | Out-Null
                            }
                        }
                    }
     
                    # In some scenarios like single-domain forest the Enterprise Admin universal group needs to be migrated.
                    ### Need to add logic to ignore it in other cases, as it may not always need to be translated.
                    # v3 {$_ -in $Constants.EntryTypeUniversalGroup} {
                    {$Constants.EntryTypeUniversalGroup -contains $_} {
                        ForEach ($MigDomain in $MigDomains) {
                            If ($Entry.Source -like "*@$($MigDomain.Source)") {
                                $MigrationTable.UpdateDestination($Entry.Source, $Entry.Source.Replace("@$($MigDomain.Source)","@$($MigDomain.Destination)")) | Out-Null
                            } ElseIf ($Entry.Source -like "$($MigDomain.Source)\*") {
                                $MigrationTable.UpdateDestination($Entry.Source, $Entry.Source.Replace("$($MigDomain.Source)\","$($MigDomain.Destination)\")) | Out-Null
                            }
                        }
                    }
     
                } # end switch
            } # end foreach
     
            $MigTablePath = Join-Path -Path $Path -ChildPath "$SourceDomain-to-$DestDomain.migtable"
            $MigrationTable.Save($MigTablePath)
     #Write-Host $MigrationTable
    
            return $MigTablePath
    }
     
    $DestDomain = (Get-ADDomain).dnsroot
    $BackupPath = 'C:\Scripts\MyLabGPOBaseBuilds\' 
    $MigTableCSVPath = "C:\Scripts\mig.csv"
    
    
    $migTable = New-GPOMigrationTable -DestDomain $DestDomain -BackupPath $BackupPath -MigTableCSVPath $MigTableCSVPath
    