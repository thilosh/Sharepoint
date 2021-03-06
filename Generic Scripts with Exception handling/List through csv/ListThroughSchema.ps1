$snapin = Get-PSSnapin | Where-Object {$_.Name -eq 'Microsoft.SharePoint.Powershell'}
if ($snapin -eq $null) {
Write-Host "Loading SharePoint Powershell Snapin"
Add-PSSnapin "Microsoft.SharePoint.Powershell"
}

$CSV = Import-Csv -path ".\ListSchema.csv"
$logFile = "LogFile_Lists.txt"

ForEach($row in $CSV)
 {
  Try
   {
        
            $site = Get-SPSite -Identity $row.SiteCollectionURL
            $web = $site.RootWeb         
           

            $libraryName = $row.Name
            $libraryDescription = $row.Description
            $TemplateName = $row.TempleteName
            #Removing the quotes as the template name to be sent should not consist of quotes
            $TemplateName = $TemplateName.Replace("""","")
            
            Write-Host -foreground "yellow" "Checking if the template - " $TemplateName "exists ..."
            Add-Content $logFile     "Checking if the template - $TemplateName exists ..." 
            
            
            $libraryTemplate = [Microsoft.SharePoint.SPListTemplateType]::$TemplateName;
            if($libraryTemplate -ne $null)
             {
                Write-Host -foreground "green" "Template - " $TemplateName " exists !!"
                Add-Content $logFile     "Template - $TemplateName  exists !!"
                Write-Host -foreground "green" "Creating Library - " $libraryName "...."
                Add-Content $logFile  "Creating Library -  $libraryName ...."
                
                # Adding Library
                $web.Lists.Add($libraryName,$libraryDescription,$libraryTemplate);
                $web.Update();
                
                Write-Host -foreground "green" "Library - " $libraryName "created Successfully !!"
                Add-Content $logFile  "Library -  $libraryName created Successfully !!"
             }
            else
             {
             
                Write-Host -foreground "red" "Template - " $TemplateName "does not exists !!"
                Add-Content $logFile  "Error :: Template -  $TemplateName does not exists !!"
             
             }
             
      
             
            #Adding CT  
            Write-Host -foreground "yellow" "Add Content Types to the Library -" $libraryName
            Add-Content $logFile  "Add Content Types to the Library - $libraryName"
            
            $docLib = $web.Lists[$libraryName]
            $docLib.ContentTypesEnabled = "True"
            $docLib.update()
            #CT will be comma separated values in the CSV,Split to get all the CT
            $customContentTypes =  $row.ContentTypes
            $customContentTypeArray = $customContentTypes.Split(",")
            foreach($customContentType in $customContentTypeArray)
               {
                 Write-Host -foreground "yellow" "Checking if the Content Type- " $customContentType "exists ..."
                 Add-Content $logFile  "Checking if the Content Type-  $customContentType exists ..."
                 
                 $customCT = $web.ContentTypes[$customContentType]
                 if($customCT -ne $null)
                    {
                         Write-Host -foreground "green" "Content Type- " $customContentType "exists !!"
                         Add-Content $logFile  "Content Type-  $customContentType exists !!"
                         
                         $CTadded = $docLib.ContentTypes.Add($customCT)
                         
                         Write-Host -foreground "green" "Content Type -"$customContentType "Added to the List - " $libraryName "Successfully !!"
                         Add-Content $logFile  "Content Type -$customContentType Added to the List - $libraryName Successfully !!"
                    } 
                 else
                    {
                         Write-Host -foreground "red" "Content Type- " $customContentType "does not exists !!"  
                         Add-Content $logFile  "Error :: Content Type- $customContentType does not exists !!" 
                    }
               }
            $docLib.update()            
          
            
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