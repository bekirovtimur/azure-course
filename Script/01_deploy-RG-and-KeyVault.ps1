$projectName = "timurbekirov-lab"
$location = "westeurope"
$upn = "Timur_Bekirov@epam.com"
$secretValue = "$X7tA0hE#SLw3" -AsSecureString
#####
$resourceGroupName = "${projectName}-rg"
$keyVaultName = $projectName
$adUserId = (Get-AzADUser -UserPrincipalName $upn).Id
$templateUri = "https://raw.githubusercontent.com/Azure/azure-docs-json-samples/master/tutorials-use-key-vault/CreateKeyVault.json"

New-AzResourceGroup -Name $resourceGroupName -Location $location
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -keyVaultName $keyVaultName -adUserId $adUserId -secretValue $secretValue

Write-Host "Press [ENTER] to continue ..."
