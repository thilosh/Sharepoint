$snapin = Get-PSSnapin | Where-Object {$_.Name -eq 'Microsoft.SharePoint.Powershell'}
if ($snapin -eq $null) {
Write-Host "Loading SharePoint Powershell Snapin"
Add-PSSnapin "Microsoft.SharePoint.Powershell"
}

$CSV = Import-Csv -path ".\SiteColumnsSchema.csv"
$logFile = "LogFile_SiteColumns.txt"

ForEach($row in $CSV)
 {
  Try
   {  
            $site = Get-SPSite -Identity $row.SiteCollectionURL
            $web = $site.RootWeb

            if($row.FieldType -eq "Number")
            {
             
                 $fieldXML = '<Field Type="'+$row.FieldType+'"
                 Name="'+$row.Name+'"
                 Description="'+$row.Description+'"
                 DisplayName="'+$row.DisplayName+'"
                 StaticName="'+$row.StaticName+'"
                 Group="'+$row.Group+'"
                 Hidden="'+$row.Hidden+'"
                 Required="'+$row.Required+'" 
                 Sealed="'+$row.Sealed+'"
                 ShowInDisplayForm="'+$row.ShowInDisplayForm+'"
                 ShowInEditForm="'+$row.ShowInEditForm+'"
                 ShowInListSettings="'+$row.ShowInListSettings+'"
                 ShowInNewForm="'+$row.ShowInNewForm+'"'
                 
                 $fieldXMLMaxValue = ""
                 if($row.MaxValueNo -ne "")
                    {
                       $fieldXMLMaxValue = ' Max="'+$row.MaxValueNo+'" '           
                    }
                    
                 $fieldXMLMinValue = ""
                 if($row.MinValueNo -ne "")
                    {
                       $fieldXMLMinValue  =  'Min="'+$row.MinValueNo+'"'
                    }
                
                 $fieldXML =   $fieldXML +  $fieldXMLMaxValue +  $fieldXMLMinValue + "></Field>" 
                                         
                 write-host -foreground "green" "Adding Site Column -" $row.Name 
                 $logRowName = $row.Name 
                 Add-Content $logFile     "Adding Site Column -$logRowName"      
                     
                 # Create Site Column from XML string
                 $web.Fields.AddFieldAsXml($fieldXML)
                 
                 write-host -foreground "green" "Site Column -" $row.Name "added Successfully !!"
                 Add-Content $logFile     "Site column -$logRowName added Successfully !!" 
            }
            
            Elseif($row.FieldType -eq "Text")
            {
             
                 $fieldXML = '<Field Type="'+$row.FieldType+'"
                 Name="'+$row.Name+'"
                 Description="'+$row.Description+'"
                 DisplayName="'+$row.DisplayName+'"
                 StaticName="'+$row.StaticName+'"
                 Group="'+$row.Group+'"
                 Hidden="'+$row.Hidden+'"
                 Required="'+$row.Required+'"
                 MaxLength="'+$row.MaxChar+'"
                 Sealed="'+$row.Sealed+'"
                 ShowInDisplayForm="'+$row.ShowInDisplayForm+'"
                 ShowInEditForm="'+$row.ShowInEditForm+'"
                 ShowInListSettings="'+$row.ShowInListSettings+'"
                 ShowInNewForm="'+$row.ShowInNewForm+'"></Field>'            
             
                 write-host -foreground "green" "Adding Site column -" $row.Name 
                 $logRowName = $row.Name 
                 Add-Content $logFile     "Adding Site column -$logRowName"     
                     
                 # Create Site Column from XML string
                 $web.Fields.AddFieldAsXml($fieldXML)
                 
                 write-host -foreground "green" "Site Column -" $row.Name "added Successfully !!"
                 Add-Content $logFile     "Site column -$logRowName added Successfully !!" 
            }
            
            Elseif($row.FieldType -eq "Choice")
            {
                 $RemovedQuotes = $row.Choice.replace("""","")
                 [string[]] $arrayChoices = $RemovedQuotes.Split(",")
             
                 $fieldXML = '<Field Type="'+$row.FieldType+'"
                 Name="'+$row.Name+'"
                 Description="'+$row.Description+'"
                 DisplayName="'+$row.DisplayName+'"
                 StaticName="'+$row.StaticName+'"
                 Group="'+$row.Group+'"
                 Hidden="'+$row.Hidden+'"
                 Required="'+$row.Required+'"
                 MaxLength="'+$row.MaxChar+'"
                 Sealed="'+$row.Sealed+'"
                 ShowInDisplayForm="'+$row.ShowInDisplayForm+'"
                 ShowInEditForm="'+$row.ShowInEditForm+'"
                 ShowInListSettings="'+$row.ShowInListSettings+'"
                 ShowInNewForm="'+$row.ShowInNewForm+'"><CHOICES>'
                 
                 $fieldXMLChoices = ""
                 ForEach($Choice in $arrayChoices)
                  {
                     $fieldXMLChoices = $fieldXMLChoices + "<CHOICE>"+$Choice+"</CHOICE>"
                  }
                 $fieldXMLDefault = ""
                 if($row.Default -ne "")
                  {
                      $fieldXMLDefault = "<Default>"+$row.Default+"</Default>"
                  } 
                 $fieldXML = $fieldXML + $fieldXMLChoices + "</CHOICES>" + $fieldXMLDefault +  "</Field>"                
                 
                 write-host -foreground "green" "Adding Site column -" $row.Name  
                 $logRowName = $row.Name 
                 Add-Content $logFile     "Adding Site column -$logRowName"  
                     
                 # Create Site Column from XML string
                 $web.Fields.AddFieldAsXml($fieldXML)
                 
                 write-host -foreground "green" "Site column -" $row.Name "added Successfully !!"
                 Add-Content $logFile     "Site column -$logRowName added Successfully !!" 
            }
            
            Elseif($row.FieldType -eq "Note")
            {
             
                 $fieldXML = '<Field Type="'+$row.FieldType+'"
                 Name="'+$row.Name+'"
                 Description="'+$row.Description+'"
                 DisplayName="'+$row.DisplayName+'"
                 StaticName="'+$row.StaticName+'"
                 Group="'+$row.Group+'"
                 Hidden="'+$row.Hidden+'"
                 Required="'+$row.Required+'"
                 RichText="TRUE"
                 RichTextMode="Compatible" 
                 Sealed="'+$row.Sealed+'"
                 ShowInDisplayForm="'+$row.ShowInDisplayForm+'"
                 ShowInEditForm="'+$row.ShowInEditForm+'"
                 ShowInListSettings="'+$row.ShowInListSettings+'"
                 ShowInNewForm="'+$row.ShowInNewForm+'"></Field>' 
            
                 write-host -foreground "green" "Adding Site column -" $row.Name 
                 $logRowName = $row.Name 
                 Add-Content $logFile     "Adding Site column -$logRowName" 
                     
                 # Create Site Column from XML string
                 $web.Fields.AddFieldAsXml($fieldXML)
                 
                 write-host -foreground "green" "Site column -" $row.Name "added Successfully !!"
                 Add-Content $logFile     "Site column -$logRowName added Successfully !!"
            }
             
            
            Elseif($row.FieldType -eq "DateTime")
            {
             
                 $fieldXML = '<Field Type="'+$row.FieldType+'"
                 Name="'+$row.Name+'"
                 Description="'+$row.Description+'"
                 DisplayName="'+$row.DisplayName+'"
                 StaticName="'+$row.StaticName+'"
                 Group="'+$row.Group+'"
                 Hidden="'+$row.Hidden+'"
                 Required="'+$row.Required+'"
                 Format="'+$row.DateFieldType+'"
                 Sealed="'+$row.Sealed+'"
                 ShowInDisplayForm="'+$row.ShowInDisplayForm+'"
                 ShowInEditForm="'+$row.ShowInEditForm+'"
                 ShowInListSettings="'+$row.ShowInListSettings+'"
                 ShowInNewForm="'+$row.ShowInNewForm+'">'          
                 
                 $fieldXMLDefault = ""
                 if($row.Default -ne "")
                  {
                      $fieldXMLDefault = "<Default>"+$row.Default+"</Default>"
                  } 
            
                 $fieldXML = $fieldXML + $fieldXMLDefault +  "</Field>"
                 
                 write-host -foreground "green" "Adding Site column -" $row.Name 
                 $logRowName = $row.Name 
                 Add-Content $logFile     "Adding Site column -$logRowName" 
                     
                 # Create Site Column from XML string
                 $web.Fields.AddFieldAsXml($fieldXML)
                 
                 write-host -foreground "green" "Site column -" $row.Name "added Successfully !!"
                 Add-Content $logFile     "Site column -$logRowName added Successfully !!"
            }
            
            Elseif($row.FieldType -eq "Boolean")
            {
             
                 $fieldXML = '<Field Type="'+$row.FieldType+'"
                 Name="'+$row.Name+'"
                 Description="'+$row.Description+'"
                 DisplayName="'+$row.DisplayName+'"
                 StaticName="'+$row.StaticName+'"
                 Group="'+$row.Group+'"
                 Hidden="'+$row.Hidden+'"
                 Required="'+$row.Required+'"         
                 Sealed="'+$row.Sealed+'"
                 ShowInDisplayForm="'+$row.ShowInDisplayForm+'"
                 ShowInEditForm="'+$row.ShowInEditForm+'"
                 ShowInListSettings="'+$row.ShowInListSettings+'"
                 ShowInNewForm="'+$row.ShowInNewForm+'">'
                 
                 if($row.Default -eq "TRUE")
                 {
                    $fieldDeafult = "<Default>1</Default></Field>"
                 }
                 else
                 {
                     $fieldDeafult = "<Default>0</Default></Field>"
                 }
                 
                  $fieldXML =  $fieldXML + $fieldDeafult 
             
                 write-host -foreground "green" "Adding Site column -" $row.Name 
                 $logRowName = $row.Name 
                 Add-Content $logFile     "Adding Site column -$logRowName" 
                     
                 # Create Site Column from XML string
                 $web.Fields.AddFieldAsXml($fieldXML)
                 
                 write-host -foreground "green" "Site column -" $row.Name "added Successfully !!"
                 Add-Content $logFile     "Site column -$logRowName added Successfully !!"
            }
            
            Elseif($row.FieldType -eq "People")
            {
             
                 $fieldXML = '<Field Type="UserMulti"
                 Name="'+$row.Name+'"
                 Description="'+$row.Description+'"
                 DisplayName="'+$row.DisplayName+'"
                 StaticName="'+$row.StaticName+'"
                 Group="'+$row.Group+'"
                 Hidden="'+$row.Hidden+'"
                 Required="'+$row.Required+'"
                 UserSelectionMode="PeopleAndGroups" 
                 UserSelectionScope="0" 
                 Mult="TRUE" 
                 Sealed="'+$row.Sealed+'"
                 ShowInDisplayForm="'+$row.ShowInDisplayForm+'"
                 ShowInEditForm="'+$row.ShowInEditForm+'"
                 ShowInListSettings="'+$row.ShowInListSettings+'"
                 ShowInNewForm="'+$row.ShowInNewForm+'"></Field>' 
            
                 write-host -foreground "green" "Adding Site column -" $row.Name 
                 $logRowName = $row.Name 
                 Add-Content $logFile     "Adding Site column -$logRowName" 
                     
                 # Create Site Column from XML string
                 $web.Fields.AddFieldAsXml($fieldXML)
                 
                 write-host -foreground "green" "Site column -" $row.Name "added Successfully !!"
                 Add-Content $logFile     "Site column -$logRowName added Successfully !!"
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