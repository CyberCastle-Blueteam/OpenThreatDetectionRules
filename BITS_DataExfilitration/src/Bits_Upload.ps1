
param(
    [Parameter()]
    [String]$SelectMode,
    [Switch]$help
)



function BITS_IIS_Installation {

  $BitsApp = 'Web-Server','BITS'
  foreach ($App in $BitsApp)
   {
        if ((Get-WindowsFeature -Name $App|select -ExpandProperty Installed) -ne 'True')
         {
            Write-host "$App not installed"
            Write-host "[+] Installing $App ....."
            $InstallApp = Install-WindowsFeature -name $App -IncludeManagementTools
            
            if ((Get-WindowsFeature -Name $App|select -ExpandProperty Installed) -eq 'True')
                 {
                    Write-Host "installed $App Feature"
                 }

             else 

                 {
                    Write-Host "[-] Failed to Install $App Feature !"
                 }
         }

        else
            {
              Write-host  "$App already installed"
            }

   }
}
  

function Bits_Directory {

    $PsyDir= "$env:TEMP/test"

    if(Test-Path $PsyDir)
         {
             Write-Host "The Directory 'test' already exists at $env:TEMP"
         }

    else
         {
             Write-Host "The Directory 'test' not exists at $env:TEMP"
             Write-Host "[+] Creating 'test' Directory ..... "
             $CrtDir=New-Item $env:TEMP/test -ItemType Directory 
       
             if (Test-Path $PsyDir)
                 {
                     Write-host "Created 'test' Directory at $env:TEMP"
                 }
             else
                 {
                     Write-Host "[-] Failed to create 'test' Directory !"
                 }
        } 
}


  function BitsDir_Permession {

    $Acl4test = Get-Acl "$env:TEMP\test"
    $GroupAdd = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    
    if ((Get-Acl -Path $env:TEMP\test | where {$_.AccessToString -like "Everyone*FullControl*" }))
           {

               Write-Host "The New ACL already Applied on 'test' Directory"

           }
    else
           {

               Write-Host "The New acl not applied on $env:TEMP\test"
               Write-Host "[+] Appling the New Acl to $env:TEMP\test ......"
               $Acl4test.SetAccessRule($GroupAdd)
               $assign_Acl= Set-Acl "$env:TEMP\test" $Acl4test

               if ((Get-Acl -Path $env:TEMP\test | where {$_.AccessToString -like "Everyone*FullControl*" }))

                    {
                         Write-Host "Applied the new ACL to $env:TEMP\test"
                    }

               else

                    {
                        Write-Host "[-] Failed to Apply the new ACL to $env:TEMP\test !"
                    }
                
           }

}


function WebApp_Creation {    
  
    if (Get-WebApplication  -Name test)

        {
            
            Write-Host "The 'test' WebApp already exists"
        }

    else

        {
             Write-Host "The 'test' WebApp Not exists"
             Write-Host "[+] Creating The 'test' WebApp  ....."
             $Crt_VrtDir= New-WebApplication -Name "test" -Site "Default Web Site" -PhysicalPath "$env:TEMP\test" -ApplicationPool "DefaultAppPool"

             if (Get-WebApplication  -Name test)
                 {

                     Write-host "Created The 'test' WebApp "

                 }

             else
                 {

                     Write-Host "[-] Failed to create The 'test' WebApp !"

                 }
        }
}

  function Enable_DirectoryBrowsing {
      
        if ((Get-WebConfigurationProperty -filter /system.webServer/directoryBrowse -name enabled -PSPath 'IIS:\Sites\Default Web Site\test' | where {$_.Value -like "True"}))
        
            {
                Write-Host "Directory Browsing already enabled on 'test' Directory" 
            }

        else

            {
                Write-Host "The Directory Browsing is Disabled on 'test' Directory"
                Write-Host "[+] Enabling Directory Browsing of 'test' Directory"
                $Enb_DirBrws= Set-WebConfigurationProperty -filter /system.webServer/directoryBrowse -name enabled -value true -PSPath 'IIS:\Sites\Default Web Site\test'

                if ((Get-WebConfigurationProperty -filter /system.webServer/directoryBrowse -name enabled -PSPath 'IIS:\Sites\Default Web Site\test' | where {$_.Value -like "True"}))
                    
                       {
                            Write-Host "Enabled Directory Browsing of 'test' Directory"
                       }

                else
                   
                       {
                              Write-Host "[-] Failed to Enable Directory Browsing of 'test' Directory !"
                       }

              }
}
                                            
function Enable_BitsUploads{  
       $webapp = Get-Website -Name 'Default Web Site'

       if ((New-Object System.DirectoryServices.DirectoryEntry("IIS://localhost/W3SVC/$($webapp.id)/root/test")).BITSUploadEnabled)
              {

                  Write-Host "BitsUpload Already Enabled"

              }
  
        else 
       
            {
                Write-Host "BitsUploads Feature is Disabled"
                Write-Host "[+} Enabling BitsUpload Feature ....."
                $Enable_BitsUpploads = (New-Object System.DirectoryServices.DirectoryEntry("IIS://localhost/W3SVC/$($webapp.id)/root/test")).EnableBitsUploads()

                if ((New-Object System.DirectoryServices.DirectoryEntry("IIS://localhost/W3SVC/$($webapp.id)/root/test")).BITSUploadEnabled)
                   
                     {
                         Write-Host "Enabled BitsUploads Feature"

                     }
                else
                     {
                    
                        Write-Host "[-] Failed to Enable BitsUploads Feature !"

                     }
    
              }
}

function Uninstall_Bits{ 
    $BitsDir= "$env:TEMP/test"
    if (Test-Path -Path $BitsDir)

    {  
         Write-Host "The 'test' Directory exists at $env:TEMP"
         Write-Host "[+] Removing $BitsDir ...."
         $Remove_Dir = Remove-Item -Path $BitsDir -Recurse -Force
        
         if (Test-Path -Path $BitsDir)

            {
                Write-Host "Removed the 'test' Directory"
            }

         else

            {
                Write-Host "[-] Failed to remove 'test' Directory"
            }


    }

    else 

    {
          Write-Host "The 'test' Directory already Not exists!"
    }


    
    $BitsApp = 'Web-Server','BITS'

    foreach ($App in $BitsApp)
    {
        if ((Get-WindowsFeature -Name $App|select -ExpandProperty Installed) -ne 'True')
        
             {
                   Write-host "$app Feature already not Installed "
            
             }

        else

            {
              Write-Host  "$app Feature is installed"
              Write-host  "[+] Removing $App Feature ......."
              $UninstallApp = Uninstall-WindowsFeature -Name Web-Server
             
              if ((Get-WindowsFeature -Name $App|select -ExpandProperty Installed) -ne 'True')
              
                  {
                         Write-Host "Removed $App Feature" 
                  }

               else

                  {
                        Write-Host "[-] Failed to uninstall $App Feature !"
                  }

            }

   }

   if ((Uninstall-WindowsFeature -Name BITS|Select-Object -ExpandProperty RestartNeeded) -eq 'Yes')
            {
             Write-Host "Configuration Changes Requiring Server Restart !"
            }
}

if  ((Get-WMIObject win32_operatingsystem |where {$_.Name -like "*Server*"}))
{
    if ($help)
        {

		    write-host "`nDescription: A simple script that creates a BITS server to be used later for Data Exhilaration via Bitsadmin.`n[Note]: This Script Tested only on Windows Server 2019! `n`nHow to Use This Script!`n`nOptions:`n-SelectMode: Select One of the two Mode (Install/Uninstall) <Required> `n `nExample:`n.\Bits_Upload.ps1 -SelectMode Install`n.\Bits_Upload.ps1 -SelectMode Uninstall`n " 
	
        }


    elseif ($SelectMode -eq 'Install' )
        { 

            BITS_IIS_Installation
            Bits_Directory
            BitsDir_Permession
            WebApp_Creation
            Enable_DirectoryBrowsing
            Enable_BitsUploads
            write-host "Done!"
        }

    elseif($SelectMode -eq 'Uninstall')
        {
            Uninstall_Bits
        }

}
else{
"Bits Server Extension Not Suporrted for this OS Product"
}