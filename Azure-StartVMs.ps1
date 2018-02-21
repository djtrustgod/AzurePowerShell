
#First, sign into your Azure account.
Login-AzureRMAccount


# Set up key variables
$subscrName="<YourSubscriptionName>"
$rgName="<YourResourceGroupName>"
$locName="<YourAzureRegionName>"
$dnsName="<InterentDNSAddressName>"
$server1 ="adVM"
$server2 ="sqlVM"
$server3 ="spVM"
$server4 ="owaVM"



#Set your Azure subscription with the following commands. 
Get-AzureRmSubscription -SubscriptionName $subscrName | Select-AzureRmSubscription

Start-AzureRmVM -Name $server1 -ResourceGroupName $rgName
Start-AzureRmVM -Name $server2 -ResourceGroupName $rgName
Start-AzureRmVM -Name $server3 -ResourceGroupName $rgName
Start-AzureRmVM -Name $server4 -ResourceGroupName $rgName

#Darrell- I added this to get full status of VMs after one minute
Start-Sleep -s 60
Get-AzureRmVM -Name $server1 -ResourceGroupName $rgName
Get-AzureRmVM -Name $server2 -ResourceGroupName $rgName
Get-AzureRmVM -Name $server3 -ResourceGroupName $rgName
Get-AzureRmVM -Name $server4 -ResourceGroupName $rgName
