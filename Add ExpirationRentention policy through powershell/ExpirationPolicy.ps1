$snapin = Get-PSSnapin | Where-Object {$_.Name -eq 'Microsoft.SharePoint.Powershell'}
if ($snapin -eq $null) {
Write-Host "Loading SharePoint Powershell Snapin"
Add-PSSnapin "Microsoft.SharePoint.Powershell"
}
$logFile = "LogFile_RDM_Expiration_Policy"

function AddExpirationPolicy($web , $contentTypes)
 {
     try
     {
        $arrayCT = $contentTypes.Split(",")
        foreach($CT in $arrayCT)
         {
              Write-host -for yellow "Checking if the Content type" $CT "exists ?"
              Add-Content $logFile "Checking if the Content type $CT exists ?"
              $CT = $web.ContentTypes[$CT]
              if($CT -ne $null)
              {
                Write-host -ForegroundColor green "Content Types -" $CT.Name  "exists !!"
                Add-Content $logFile "Content Types - $CT.Name exists !!"
                $policy=[Microsoft.Office.RecordsManagement.InformationPolicy.Policy]::GetPolicy($CT);
                 if ($policy -eq $null)
                   {
                    $policy=[Microsoft.Office.RecordsManagement.InformationPolicy.Policy]:: CreatePolicy($CT,$null);
                    $policy=[Microsoft.Office.RecordsManagement.InformationPolicy.Policy]::GetPolicy($CT);
                   }
                $policy.Description="RDM expiration Policy";
                $policy.Statement="RDM expiration Policy";
                $policy.Update();
                $expirypolicyexists=$false;
                if ($policy.Items.Count -ne 0)
                {
                foreach ($policyitem in $policy.Items)
                {
                    if ($policyitem.Name -eq "Retention")
                    {
                        $expirypolicyexists=$true;
                    }
                }
                }
                if ($expirypolicyexists -eq $false)
                 {
                $policyFeatureID = [Microsoft.Office.RecordsManagement.PolicyFeatures.Expiration];
                #Expires data when the current date is equal to the document date set for the record       
                $customData = '<Schedules nextStageId="2">
                                <Schedule type="Default">
                                <stages>
                                  <data stageId="1">
                                    <formula id="Microsoft.Office.RecordsManagement.PolicyFeatures.Expiration.Formula.BuiltIn">
                                      <number>0</number>
                                      <property>DocumentDate</property>                          
                                      <period>days</period>
                                    </formula>
                                    <action type="action" id="Microsoft.Office.RecordsManagement.PolicyFeatures.Expiration.Action.MoveToRecycleBin" />
                                  </data>
                                </stages>
                              </Schedule>
                            </Schedules>'
                $policy.Items.Add($policyFeatureID,$customData);
                #$policy.Items.Add("Microsoft.Office.RecordsManagement.PolicyFeatures.Expiration",$customData);
                $policy.Update();
                Write-Host -ForegroundColor Green  "Expiration  policy added for thr Content Type -" $CT.Name
                Add-Content $logFile "Expiration  policy added for thr Content Type - $CT.Name"
                 }
                else
                 {
                   Write-Host -ForegroundColor Red  "An expiry policy already exists and is not overwritten for the Content type -" $CT.Name
                   Add-Content $logFile   "An expiry policy already exists and is not overwritten for the Content type - $CT.Name"
                 }
              }
              else
              {
                Write-host -ForegroundColor red "Content Types -" $CT  "doesnot exists !!"
                Add-Content $logFile "Content Types - $CT doesnot exists !!"
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
 }

 $siteURL = Read-Host "Enter the Site collection URL - Eg:http://tbttsecm48d:1234/ " 
 $site = Get-SPSite -Identity  $siteURL 
 $web = $site.RootWeb 
 $contentTypes =  "RE Document,PMA Lease Document,PMA CAMP Documents,PMA CAMR Documents,RECR Supporting,PMA CAMP Supporting,PMA CAMR Supporting,PMA Lease Supporting,RDM Migration"

 AddExpirationPolicy $web $contentTypes
 
 $web.Dispose();
 $site.Dispose();
 



Read-Host "Press enter Key to exit !!"