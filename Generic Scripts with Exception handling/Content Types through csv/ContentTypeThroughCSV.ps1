$snapin = Get-PSSnapin | Where-Object {$_.Name -eq 'Microsoft.SharePoint.Powershell'}
if ($snapin -eq $null) {
Write-Host "Loading SharePoint Powershell Snapin"
Add-PSSnapin "Microsoft.SharePoint.Powershell"
}

$CSV = Import-Csv -path ".\ContentTypesSchema.csv"
$logFile = "LogFile_ContentTypes.txt"

ForEach($row in $CSV)
 {
  Try
   {
 
            $site = Get-SPSite -Identity $row.SiteCollectionURL
            $web = $site.RootWeb
            $logRowName = $row.Name
            
            if($row.Type -eq "ContentType")
            {
            
                Write-Host -foreground "green" "Creating Content Type- "$row.Name                
                Add-Content $logFile    "Creating Content Type- $logRowName" 
                
                $ctypeName = $row.Name
                $ctypeParent = $web.availablecontenttypes[$row.Parent]
                if($ctypeParent -ne $null)
                {
                    $ctype = new-object Microsoft.SharePoint.SPContentType($ctypeParent, $web.contenttypes, $ctypeName)
                    $ctype.Group = $row.Group
                    $ctype.Description = $row.Description
                    $result = $web.contenttypes.add($ctype)
                    Write-Host -foreground "green" "Content Type-"$result.Name "created Successfully !!"
                    Add-Content $logFile    "Creating Content Type- $logRowName created Successfully !!" 
                }
                else
                {
                    Write-Host -foreground "red" "Parent Content Type-" $row.Parent "Not found !!"
                    Add-Content $logFile    "Parent Content Type- $logRowName created Not found !!"
                    
                }     
               
            }  
            
            Elseif($row.Type -eq "Column")
            {
               Write-Host -foreground "yellow" "Checking if the column-"$row.Name "Exists in site"
               Add-Content $logFile    "Checking if the column- $logRowName Exists in site"
               
                $field = $web.fields.getfield($row.Name)               
                if($field -ne $null)
                    {
                        Write-Host -foreground "green" "column -"$row.Name "Exists !!"
                        Add-Content $logFile    "column - $logRowName Exists !!" 
                        $LogRowParent = $row.Parent               
                        if($row.Action -eq "Add")
                            {
                                Write-Host -foreground "green" "Adding Column -"$row.Name "to the Content Type" $row.Parent                                
                                Add-Content $logFile    "Adding Column -$logRowName to the Content Type $LogRowParent"
                                
                                $ctype = $web.ContentTypes[$row.Parent]
                                if($ctype -ne $null)
                                    {
                                         Write-Host -foreground "yellow" "Content type exists - " $row.Parent
                                         Add-Content $logFile  "Content type exists- $LogRowParent"
                                         
                                         $fieldLink = new-object Microsoft.SharePoint.SPFieldLink($field)
                                         $ctype.fieldlinks.add($fieldLink)
                                         $ctype.update() 
                                         Write-Host -foreground "green" "Adding Column -"$row.Name "to the Content Type" $row.Parent "was Successfull !!" 
                                         Add-Content $logFile    "Adding Column -$logRowName to the Content Type $LogRowParent was Successfull !!"                         
                                    }
                                else
                                    {
                                    
                                        Write-Host -foreground "red" "Content type does not exists - " $row.Parent
                                        Add-Content $logFile    "Error :: Content type does not exists -$LogRowParent "                         
                                    }
                                
                            }
                            
                           Elseif($row.Action -eq "Delete")
                            {
                                Write-Host -foreground "green" "Deleting Column -"$row.Name "from the Content Type" $row.Parent
                                Add-Content $logFile    "Deleting Column- $logRowName from the Content Type $LogRowParent"  
                                
                                $ctype = $web.ContentTypes[$row.Parent]
                                if($ctype -ne $null)
                                    {
                                         Write-Host -foreground "yellow" "Content type exists - " $row.Parent
                                         Add-Content $logFile    "Content type exists - $LogRowParent"
                                         
                                         $fieldLink = new-object Microsoft.SharePoint.SPFieldLink($field)
                                         $ctype.fieldlinks.Delete($fieldLink.Id)
                                         $ctype.update()
                                         Write-Host -foreground "green" "Deleting Column -"$row.Name "from the Content Type" $row.Parent "was Successful !!"  
                                         Add-Content $logFile    "Deleting Column -$logRowName from the Content Type $LogRowParent was Successfull !!"                         
                                    }
                                else
                                    {
                                    
                                        Write-Host -foreground "red" "Content type does not exists - " $row.Parent
                                        Add-Content $logFile    "Error :: Content type does not exists -$LogRowParent " 
                                    }
                                
                            }
                    }
                else
                    {
                         Write-Host -foreground "red" "column -"$row.Name " doesnot Exists in the site!!"
                         Add-Content $logFile    "Error :: column -logRowName does not exists  " 
                    }
               
               
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