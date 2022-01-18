# Define variables
$projectName = "timurbekirov-lab"
$location = "westeurope"
$resourceGroupName = "${projectName}-rg"
$recoveryServicesVaultName = "${projectName}-rsv"
$storageAccountName = "satimurbekirov"
$vmName = "vm-timurbekirov-lab"
$tag = @{"owner"="Timur_Bekirov"}
$blobContainerName = "${projectName}-blobs"
$shareName = "${projectName}-share"
$ScriptConnectSMB = "connect_share_folder.ps1"
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
#
$runCmdString = "$ScriptConnectSMB -keypass `"$storageAccountKey`""
Write-Output "Please wait. Deploying Custom Script Extension. This process may take up to 15 minutes. If you do not need to wait, just add -NoWait parameter in future deployments"
Write-Output "Run cmd string is: `"$runCmdString`""
Set-AzVMCustomScriptExtension `
  -Name "${projectName}-CSE" `
  -ResourceGroupName $resourceGroupName `
  -VMName $vmName `
  -Run $runCmdString `
  -Location $location `
  -FileUri $blobUri
Write-Output "Conncting SMB to VM completed"
#
Restart-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
#
Set-AzVMCustomScriptExtension `
  -Name "${projectName}-CSE" `
  -ResourceGroupName $resourceGroupName `
  -VMName $vmName `
  -Run $runCmdString `
  -Location $location `
  -FileUri $blobUri
#
