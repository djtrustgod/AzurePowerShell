#created with guidelines from https://technet.microsoft.com/library/mt723354(v=office.16).aspx - My New Mod Create a generic windows server for Office Online Server
# Log in to Azure
Login-AzureRmAccount

# Set up key variables
$subscrName="BizSpark"
$rgName="DGSP2016"
$locName="West US"
$dnsName="deglowasrv"

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

#Note: next steps involve adding the server to the local domain
#Connect to the  virtual machine using the credentials of the local administrator account.
#Join the SharePoint virtual machine to the Windows Server AD domain with these commands at the Windows PowerShell prompt.

#      Add-Computer -DomainName "corp.terracificenergy.com"
#      Restart-Computer