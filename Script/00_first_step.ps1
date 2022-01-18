Import-Module az
Connect-AzAccount
Write-Output "Current subscription is $((Get-AzSubscription).Name)"
Select-AzSubscription -SubscriptionName "EPM-RDSP"

#Register-AzResourceProvider -ProviderNamespace "Microsoft.RecoveryServices"
#Get-AzResourceProvider -ProviderNamespace "Microsoft.RecoveryServices"
