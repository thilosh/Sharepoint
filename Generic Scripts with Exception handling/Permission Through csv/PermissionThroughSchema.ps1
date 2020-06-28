$snapin = Get-PSSnapin | Where-Object {$_.Name -eq 'Microsoft.SharePoint.Powershell'}
if ($snapin -eq $null) {
Write-Host "Loading SharePoint Powershell Snapin"
Add-PSSnapin "Microsoft.SharePoint.Powershell"
}

$CSV = Import-Csv -path ".\PermissionSchema.csv"
$logFile = "LogFile_Permission.txt"

ForEach($row in $CSV)
 {
  Try
   {
 
            $site = Get-SPSite -Identity $row.SiteCollectionURL
            $web = $site.RootWeb

            if($row.Scope -eq "Site")
              {
                $groupName = $row.Group
                
                Write-Host  -foreground "yellow"  "Checking if the Sharepoint group -"  $groupName "exists !!"
                Add-Content $logFile "Checking if the Sharepoint group -$groupName exists !!"
                
                $Group = $web.SiteGroups[$groupName]
                if($Group -eq $null)
                {
                    Write-Host  -foreground "green"  "Sharepoint group -"  $groupName "does not exists in Site !!"
                    Add-Content $logFile  "Sharepoint group - $groupName does not exists in Site !!"
                    Write-Host  -foreground "green"  "Creating Sharepoint group -"  $groupName " ...."
                    Add-Content $logFile  "Creating Sharepoint group - $groupName"
                    
                    $web.SiteGroups.Add($groupName,$web.Site.Owner,$web.Site.Owner,$row.GroupDescription)
                    $Group = $web.SiteGroups[$groupName]
                    $Group.AllowMembersEditMembership = $true
                    $Group.Update()
                    Write-Host  -foreground "green"  "Creating role assignment for the group -" $groupName "...."
                    Add-Content $logFile  "Creating role assignment for the group - $groupName"

                    $GroupAssignment = new-object Microsoft.SharePoint.SPRoleAssignment($Group)
                    #Get the permission levels to apply to the new groups
                    $RoleDefinition = $web.Site.RootWeb.RoleDefinitions[$row.PermissionLevel]
                    #Assign the groups the appropriate permission level
                    $GroupAssignment.RoleDefinitionBindings.Add($RoleDefinition)
                    #Add the group to the site with the permission level
                    $web.RoleAssignments.Add($GroupAssignment)

                    Write-Host  -foreground "green"  "Creation of group and role assignment completed successfully for the group -" $groupName
                    Add-Content $logFile  "Creation of group and role assignment completed successfully for the group - $groupName"

                    #Adding users to the group
                    Write-Host  -foreground "green"  "Adding users to the group -" $groupName
                    Add-Content $logFile  "Adding users to the group - $groupName"
                    $users = $row.Users
                    $arrayUsers = $users.split(",")
                    foreach($user in $arrayUsers)
                        {
                           if($user -ne "")
                             {
                               $adUser = $web.Site.RootWeb.EnsureUser($user)
                               $Group.AddUser($adUser)
                             }
                        }

                }
                else
                 {
                    Write-Host  -foreground "green"  "Sharepoint group -"  $groupName "already exists in Site !! No changes are performed on the Group"
                    Add-Content $logFile  "Sharepoint group -$groupName already exists in Site !! No changes are performed on the Group"
                    
                  }
            
              }
              
              Elseif($row.Scope -eq "List")
               {
                    $groupName = $row.Group
                    $listName = $row.ListName
                    #Break Roleinherentence for the list
                    
                    $list = $web.Lists[$listName]
                    Write-Host  -foreground "yellow" "Checking if the List - " $listName " has unique permissions ...."
                    Add-Content $logFile  "Checking if the List -  $listName  has unique permissions"
                    
                    if(-Not($list.HasUniqueRoleAssignments))
                    {
                        Write-Host  -foreground "green" "Breaking Role inherentence for the list - " $listName
                        Add-Content $logFile  "Breaking Role inherentence for the list -  $listName"
                        $list.BreakRoleInheritance($false)                
                       
                    }
                    Write-Host  -foreground "green" "List - " $listName "has unique permissions !!"
                    Add-Content $logFile  "List - $listName has unique permissions !!"
                    Write-Host  -foreground "green" "Adding security Group-" $groupName "to the List "
                    Add-Content $logFile  "Adding security Group- $groupName to the List "
                                  
                        $Group = $web.SiteGroups[$groupName] 
                        $GroupAssignment = new-object Microsoft.SharePoint.SPRoleAssignment($Group)
                        #Get the permission levels to apply to the new groups
                        $RoleDefinition = $web.Site.RootWeb.RoleDefinitions[$row.PermissionLevel]
                        #Assign the groups the appropriate permission level
                        $GroupAssignment.RoleDefinitionBindings.Add($RoleDefinition)
                        #Add the group to the site with the permission level
                        $list.RoleAssignments.Add($GroupAssignment)     
                        $list.Update()
                    Write-Host  -foreground "green" "Security group- "$groupName "added to the List -"   $listName "Successfully !!"
                    Add-Content $logFile "Security group- $groupName added to the List - $listName Successfully !!"
                                  
              
               }           
           
            
   }
 catch
  {
  
         Write-Host  $_.Exception.Message
        
         Add-Content $logFile    "***Error description Starts****`n"
         Add-Content $logFile    $_.Exception.Message         
         Add-Content $logFile    "***Error description ends****`n"
  
  
  }
 Finally
  {
  
        $web.Dispose()
        $site.Dispose()
  
  }   
   

}

Read-host "Press Enter key to Exit......."