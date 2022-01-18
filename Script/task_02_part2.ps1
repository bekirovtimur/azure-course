# Define variables
$projectName = "timurbekirov-lab"
$location = "westeurope"
$resourceGroupName = "${projectName}-rg"
$recoveryServicesVaultName = "${projectName}-rsv"
$storageAccountName = "satimurbekirov"
$vmName = "vm-timurbekirov-lab"
$tag = @{"owner"="Timur_Bekirov"}
$blobContainerName = "${projectName}-blobs"
$ScriptConnectSMB = "connect_share_folder.ps1"
#

###########
$shareName = "${projectName}-share"
#
# 3) Create Azure File Share.
New-AzRmStorageShare `
  -ResourceGroupName $resourceGroupName `
  -StorageAccountName $storageAccountName `
  -Name $shareName
#
# 4) Connect new File Share as drive X: to VM, created at 1st day, using Custom script extension.

# Uploading script to blob container:
$ctx = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName).Context
#
Set-AzStorageBlobContent -File $ScriptConnectSMB `
  -Container $blobContainerName `
  -Blob $ScriptConnectSMB `
  -Context $ctx `
  -StandardBlobTier Cool #[Cool, Hot, Archive]
#
# Deploying Custom Script Extension:
$blobUri = (Get-AzStorageBlob -blob $ScriptConnectSMB -Container $blobContainerName -Context $ctx).ICloudBlob.uri.AbsoluteUri
$storageAccountKey = `
    (Get-AzStorageAccountKey `
    -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName).Value[0]
#
$runCmdString = "$ScriptConnectSMB -keypass $storageAccountKey"
Write-Output $runCmdString

Write-Output "Please wait. Deploying Custom Script Extension. This process may take up to 15 minutes. If you do not need to wait, just add -NoWait parameter in future deployments"
Set-AzVMCustomScriptExtension `
  -Name "${projectName}-CSE" `
  -ResourceGroupName $resourceGroupName `
  -VMName $vmName `
  -Run $runCmdString `
  -Location $location `
  -FileUri $blobUri
Write-Output "Conncting SMB to VM completed"

#(Get-AzStorageAccountKey -ResourceGroupName "timurbekirov-lab-rg" -Name satimurbekirov).Value[0] | Out-File StorageAccount.key

#5) Create new role with modify permissions, assign it to resource group with VM and add account epmcourse@outlook.com to it.
# https://docs.microsoft.com/ru-ru/azure/backup/quick-backup-vm-powershell
