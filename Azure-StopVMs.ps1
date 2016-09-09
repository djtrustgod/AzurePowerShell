
#First, sign into your Azure account.
Login-AzureRMAccount


# Set up key variables
$subscrName="BizSpark"
$rgName="DGSP2016"
$locName="West US"
$dnsName="deglsqlsp16"
$server1 ="adVM"
$server2 ="sqlVM"
$server3 ="spVM"
$server4 ="owaVM"


#Set your Azure subscription with the following commands. 
Get-AzureRmSubscription -SubscriptionName $subscrName | Select-AzureRmSubscription

Stop-AzureRmVM -Name $server1 -ResourceGroupName $rgName -Force
Stop-AzureRmVM -Name $server2 -ResourceGroupName $rgName -Force
Stop-AzureRmVM -Name $server3 -ResourceGroupName $rgName -Force
Stop-AzureRmVM -Name $server4 -ResourceGroupName $rgName -Force

