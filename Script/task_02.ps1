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
#
# 1) Create a Recovery Services vault
# 2) Configure a backup of VM, created at 1st day with automatic backup each Saturday at 00:00 GMT.
# Creating a Recovery Services vault and Weekly policy from ARM template:
$templateUri = "https://raw.githubusercontent.com/bekirovtimur/azure-course/main/ARM/Backup/template.json"
$templateParameterUri = "https://raw.githubusercontent.com/bekirovtimur/azure-course/main/ARM/Backup/parameters.json"
New-AzResourceGroupDeployment `
  -ResourceGroupName $resourceGroupName `
  -TemplateUri $templateUri `
  -TemplateParameterUri $templateParameterUri
#
# Disabling Soft Delete feature for backups:
$recoveryServicesVault = Get-AzRecoveryServicesVault -Name $recoveryServicesVaultName -ResourceGroupName $resourceGroupName
Set-AzRecoveryServicesVaultProperty -VaultId $recoveryServicesVault.ID -SoftDeleteFeatureState Disable
#
# Setting Recovery Services Vault Context:
Get-AzRecoveryServicesVault -Name $recoveryServicesVaultName -ResourceGroupName $resourceGroupName | Set-AzRecoveryServicesVaultContext
#
# Setting weekly Saturday policy to VM created in first task:
$policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name "EpamWeeklyPolicy"
Enable-AzRecoveryServicesBackupProtection `
    -ResourceGroupName $resourceGroupName `
    -Name $vmName `
    -Policy $policy
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
$runCmdString = "$ScriptConnectSMB -keypass `"$storageAccountKey`""
Write-Output "Please wait. Deploying Custom Script Extension. This process may take up to 15 minutes. If you do not need to wait, just add -NoWait parameter in future deployments"
Set-AzVMCustomScriptExtension `
  -Name "${projectName}-CSE" `
  -ResourceGroupName $resourceGroupName `
  -VMName $vmName `
  -Run $runCmdString `
  -Location $location `
  -FileUri $blobUri
Write-Output "Conncting SMB to VM completed"
#
# 5) Create new role with modify permissions, assign it to resource group with VM and add account epmcourse@outlook.com to it.
# No rights to add roles on epam account!
#
# And setting tag 'owner' to all my resources:
$resource = Get-AzResource -ResourceGroupName $resourceGroupName
$resource | ForEach-Object { New-AzTag -Tag $tag -ResourceId $_.ResourceId }
Write-Output "Tagging completed"
#
# All done!
Write-Output "All done!"
