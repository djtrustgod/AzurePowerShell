#created with guidelines from https://technet.microsoft.com/library/mt723354(v=office.16).aspx - Part 1 Deploy the virtual network and a domain controller
#These commands are for Azure PowerShell 1.0 and later.

#First, sign into your Azure account.
Login-AzureRMAccount

#Get your subscription name using the following command.
Get-AzureRMSubscription | Sort SubscriptionName | Select SubscriptionName

#Set your Azure subscription with the following commands. 
#Set the $subscr variable by replacing everything within the quotes, 
#including the < and > characters, with the correct name
$subscr="<subscription name>"
Get-AzureRmSubscription -SubscriptionName $subscr | Select-AzureRmSubscription

#For the rest of the commands go to https://technet.microsoft.com/library/mt723354(v=office.16).aspx