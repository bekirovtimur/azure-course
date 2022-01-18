# Define variables
$projectName = "timurbekirov-lab"
$location = "westeurope"
$resourceGroupName = "${projectName}-rg"
$recoveryServicesVaultName = "${projectName}-rsv"
$storageAccountName = "satimurbekirov"
$vmName = "vm-timurbekirov-lab"
$tag = @{"owner"="Timur_Bekirov"}
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
###########
#
# 3) Create Azure File Share.

      #4) Connect new File Share as drive X: to VM, created at 1st day, using Custom script extension.

      #5) Create new role with modify permissions, assign it to resource group with VM and add account epmcourse@outlook.com to it.
      # https://docs.microsoft.com/ru-ru/azure/backup/quick-backup-vm-powershell
