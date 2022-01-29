# Define variables
$projectName = "timurbekirov-lab"
$location = "westeurope"
$upn = "Timur_Bekirov@epam.com"
$secretValue = Read-Host -Prompt "Enter the VM administrator password" -AsSecureString
$resourceGroupName = "${projectName}-rg"
$storageAccountName = "satimurbekirov"
$vmName = "vm-timurbekirov-lab"
$ScriptDeployIISfilename = "install_iis.ps1"
$tag = @{"owner"="Timur_Bekirov"}
#
# 1) Deploy a resource group. And Azure KeyVault#
$keyVaultName = $projectName
$adUserId = (Get-AzADUser -UserPrincipalName $upn).Id
$templateUri = "https://raw.githubusercontent.com/bekirovtimur/azure-course/main/ARM/KeyVault/template.json"
#
# Creating new resource group:
New-AzResourceGroup `
  -Name $resourceGroupName `
  -Location $location
#
# Creating new KeyVault:
New-AzResourceGroupDeployment `
  -ResourceGroupName $resourceGroupName `
  -TemplateUri $templateUri `
  -keyVaultName $keyVaultName `
  -adUserId $adUserId `
  -secretValue $secretValue
#
Write-Output "Deploying Resource Group and Key Vault completed"
#############################################
# 2) Deploy a new virtual machine, using ARM template:
# • Use the resource group above
# • Operating system: Windows any
# • Location, VM size, Storage – to your discretion
# • Password must be stored in Azure KeyVault (please deploy it first)
#
# Deploying VM from ARM template with parameters
$templateUri = "https://raw.githubusercontent.com/bekirovtimur/azure-course/main/ARM/VM/template.json"
$templateParameterUri = "https://raw.githubusercontent.com/bekirovtimur/azure-course/main/ARM/VM/parameters.json"
#
New-AzResourceGroupDeployment `
  -ResourceGroupName $resourceGroupName `
  -TemplateUri $templateUri `
  -TemplateParameterUri $templateParameterUri
#
Write-Output "Deploying VM completed"
#############################################
# 3) Deploy IIS to the VM above, using Custom script extension (you should create an azure storage account for that first)
#
# Creating Azure Storage account:
$StorageHT = @{
  ResourceGroupName = $resourceGroupName
  Name              = $storageAccountName
  SkuName           = "Standard_LRS"
  Location          = $location
}
$StorageAccount = New-AzStorageAccount @StorageHT
$ctx = $StorageAccount.Context
#
# Creating blob container:
$blobContainerName = "${projectName}-blobs"
New-AzStorageContainer `
  -Name $blobContainerName `
  -Context $ctx `
  -Permission blob
#
# Uploading script to blob container:
Set-AzStorageBlobContent -File $ScriptDeployIISfilename `
  -Container $blobContainerName `
  -Blob $ScriptDeployIISfilename `
  -Context $ctx `
  -StandardBlobTier Cool #[Cool, Hot, Archive]
#
# Deploying Custom Script Extension:
$blobUri = (Get-AzStorageBlob -blob $ScriptDeployIISfilename -Container $blobContainerName -Context $ctx).ICloudBlob.uri.AbsoluteUri
#
Write-Output "Please wait. Deploying Custom Script Extension. This process may take up to 15 minutes. If you do not need to wait, just add -NoWait parameter in future deployments"
Set-AzVMCustomScriptExtension `
  -Name "${projectName}-CSE" `
  -ResourceGroupName $resourceGroupName `
  -VMName $vmName `
  -Run $ScriptDeployIISfilename `
  -Location $location `
  -FileUri $blobUri
Write-Output "Deploying IIS to the VM completed"
#
# Setting tag 'owner' to my resource group:
$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName
New-AzTag -ResourceId $resourceGroup.ResourceId -tag $tag
#
# And setting tag 'owner' to all my resources:
$resource = Get-AzResource -ResourceGroupName $resourceGroupName
$resource | ForEach-Object { New-AzTag -Tag $tag -ResourceId $_.ResourceId }
Write-Output "Tagging completed"
#
# All done!
$vmIPaddress = (Get-AzPublicIpAddress -Name "${vmName}-ip" -ResourceGroupName $resourceGroupName).IpAddress
Write-Output "All done, open http://$vmIPaddress in your browser."
