#created with guidelines from https://technet.microsoft.com/library/mt723354(v=office.16).aspx - My New Mod Create a generic windows server for Office Online Server
# Log in to Azure
Login-AzureRmAccount

# Set up key variables
$subscrName="<YourSubscriptionName>"
$rgName="<YourResourceGroupName"
$locName="<YourAzureRegionName>"
$dnsName="<InterentDNSAddressName)"

# Set the Azure subscription
Get-AzureRmSubscription -SubscriptionName $subscrName | Select-AzureRmSubscription

# Get the Azure storage account name
$sa=Get-AzureRMStorageaccount | where {$_.ResourceGroupName -eq $rgName}
$saName=$sa.StorageAccountName

# Create an availability set for virtual machine
New-AzureRMAvailabilitySet -Name owaAvailabilitySet -ResourceGroupName $rgName -Location $locName

# Specify the virtual machine name and size
$vmName="owaVM"
$vmSize="Standard_D3_V2"
$vm=New-AzureRMVMConfig -VMName $vmName -VMSize $vmSize

# Create the NIC for the virtual machine
$nicName=$vmName + "-NIC"
$pipName=$vmName + "-PublicIP"
$pip=New-AzureRMPublicIpAddress -Name $pipName -ResourceGroupName $rgName -DomainNameLabel $dnsName -Location $locName -AllocationMethod Dynamic
$vnet=Get-AzureRMVirtualNetwork -Name "SP2016Vnet" -ResourceGroupName $rgName
$nic=New-AzureRMNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -PrivateIpAddress "10.0.0.7"
$avSet=Get-AzureRMAvailabilitySet -Name owaAvailabilitySet -ResourceGroupName $rgName 
$vm=New-AzureRMVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $avSet.Id

# Specify the image and local administrator account, and then add the NIC
# Note from Darrell - This also gets the VMSource image for Windows Server
$pubName="MicrosoftWindowsServer"
$offerName="WindowsServer"
$skuName="2012-R2-Datacenter"
$cred=Get-Credential -Message "Type the name and password of the local administrator account."
$vm=Set-AzureRMVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm=Set-AzureRMVMSourceImage -VM $vm -PublisherName $pubName -Offer $offerName -Skus $skuName -Version "latest"
$vm=Add-AzureRMVMNetworkInterface -VM $vm -Id $nic.Id

# Specify the OS disk name and create the VM
$diskName="OSDisk"
$storageAcc=Get-AzureRMStorageAccount -ResourceGroupName $rgName -Name $saName
$osDiskUri=$storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $vmName + $diskName  + ".vhd"
$vm=Set-AzureRMVMOSDisk -VM $vm -Name $diskName -VhdUri $osDiskUri -CreateOption fromImage
New-AzureRMVM -ResourceGroupName $rgName -Location $locName -VM $vm

#Darrell- I added this to get full status of VM after one minute
Start-Sleep -s 60
Get-AzureRmVM -Name owaVM -ResourceGroupName DGSP2016

#########

#Next steps involve adding the server to the local domain
#Connect to the  virtual machine using the credentials of the local administrator account.
#Then Join the SharePoint virtual machine to the Windows Server AD domain with these commands at the Windows PowerShell prompt.

#      Add-Computer -DomainName "corp.terracificenergy.com"
#      Restart-Computer

#########

#Next Steps involved installing the prerequistes for the Office Online Server
#Run these commands in PowerShell when logged into the server as the domain admin or a domain account with admin rights to the local server:

#     Install-WindowsFeature Web-Server, Web-Mgmt-Tools, Web-Mgmt-Console, Web-WebServer, Web-Common-Http, Web-Default-Doc, Web-Static-Content, Web-Performance, Web-Stat-Compression, Web-Dyn-Compression, Web-Security, Web-Filtering, Web-Windows-Auth, Web-App-Dev, Web-Net-Ext45, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Includes, InkandHandwritingServices
#     Add-WindowsFeature Windows-Identity-Foundation

########

#Now run the the Office Online Server installer on your Office Online Server
#While restarting the server following the sintall get the fully qualfied public domain name of the Office Online Server, 
#by runing this powershell from your local Azure Account connected Powershell
$pip = Get-AzureRMPublicIpaddress -Name "owaVM-PublicIP" -ResourceGroup $rgName
$pip.DnsSettings.Fqdn 

########

#Next run this on the Office Online Server's Powershell.  Note - this assumes Alternate Access Mappings have been created in SharePoint for Internet / Internal Zones
# There's alot of options to this new Office Web Apps farm - see https://technet.microsoft.com/en-us/library/jj219436.aspx

#Code    New-OfficeWebAppsFarm -AllowHttp -ExternalURL http://deglowasrv.westus.cloudapp.azure.com -InternalURL http://owaVM"
#Then enable editing - This was not in the online docs. 
#Code    Set-OfficeWebAppsFarm -EditingEnabled

# Test the result by navigating to your server path like http://deglowasrv.westus.cloudapp.azure.com/hosting/discovery  - You should get an XML doc

#######

#Next go to your SharePoint Server and run the Powershell to bind your Office Web App farm to SP 
# I used this website to guide me, 
#http://www.learningsharepoint.com/2015/11/03/configure-office-online-server-owa-for-sharepoint-2016-azure-virtual-machine/

#on your SP Server Powershell run this command.  In my case I connected the SP server to the external URL of the Office Web App server set up earlier
#Code   New-SPWOPIBinding -ServerName "deglowasrv.westus.cloudapp.azure.com" -AllowHTTP

#Office Web Apps Server uses zones to determine which URL (internal or external) and which protocol (HTTP or HTTPS) 
#to use when opening Office Online Server. Check your URL and Protocol by running the command below on Your SharePoint server

#Code    Get-SPWOPIZone
# the default is internal-https, but in my case I wanted to use SharePoint/Office Web apps via my public azure add so I ran following command on the SharePoint server:

#Code    Set-SPWOPIZone external-http


#If this is a Dev environment using http, On your SharePoint Server run this PowerShell command to see if authentication over http is allowed:
#    (Get-SPSecurityTokenServiceConfig).AllowOAuthOverHttp

# If False, run the following commands on your SharePoint Server powershell to set this to True.

#Code    $config = (Get-SPSecurityTokenServiceConfig)
#Code    $config.AllowOAuthOverHttp = $true
#Code    $config.Update() 

# Next, I did an superstitous IISreset and by default Office Web Apps started working

