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
New-AzRecoveryServicesVault `
  -Name $recoveryServicesVaultName `
  -ResourceGroupName $resourceGroupName `
  -Location $location

$recoveryServicesVault = Get-AzRecoveryServicesVault -Name $recoveryServicesVaultName -ResourceGroupName $resourceGroupName

Set-AzRecoveryServicesBackupProperty `
  -Vault $recoveryServicesVault `
  -BackupStorageRedundancy LocallyRedundant

# Creating new policy
$schPol = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType "AzureVM"
$UtcTime = Get-Date -Date "2022-01-01 00:00:00Z"
$UtcTime = $UtcTime.ToUniversalTime()
$schPol.ScheduleRunTimes[0] = $UtcTime
$schPol.ScheduleRunFrequency = "Weekly"
$schPol.ScheduleRunDays = "Sunday"
#$schPol.ScheduleRunDays = "Saturday" #Saturday NOT WORKING! Azure bug https://github.com/Azure/azure-powershell/issues/12136
#
$retPol = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureVM"
$retPol.IsDailyScheduleEnabled = $false
$retPol.IsWeeklyScheduleEnabled = $true
#
New-AzRecoveryServicesBackupProtectionPolicy -Name "EpamWeeklyPolicy" -WorkloadType "AzureVM" -RetentionPolicy $retPol -SchedulePolicy $schPol -VaultId $recoveryServicesVault.ID
###

#
# Setting weekly Saturday policy to VM
$policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name "EpamWeeklyPolicy"
$schPol.ScheduleRunDays = "Saturday"
Set-AzRecoveryServicesBackupProtectionPolicy -Policy $policy -RetentionPolicy $retPol -SchedulePolicy $schPol
#Enable-AzRecoveryServicesBackupProtection `
#    -ResourceGroupName $resourceGroupName `
#    -Name $vmName `
#    -Policy $policy


#Get-AzRecoveryServicesVault -Name $recoveryServicesVaultName -ResourceGroupName $resourceGroupName | Set-AzRecoveryServicesVaultContext

# # # # # # # Getting VaultID examples # # # # # # #
# $targetVaultID = Get-AzRecoveryServicesVault -ResourceGroupName $resourceGroupName -Name $recoveryServicesVaultName | select -ExpandProperty ID
# or
# $targetVault = Get-AzRecoveryServicesVault -Name $recoveryServicesVaultName -ResourceGroupName $resourceGroupName
# $targetVault.ID
# # # # # # # # # # # # # # # # # # # # # # # # # #

#Get-AzRecoveryServicesBackupProtectionPolicy -WorkloadType "AzureVM" -VaultId $recoveryServicesVault.ID

#$schPol = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType "AzureVM"
#$UtcTime = Get-Date -Date "2022-01-01 00:00:00Z"
#$UtcTime = $UtcTime.ToUniversalTime()
#$schPol.ScheduleRunTimes[0] = $UtcTime
#$schPol.ScheduleRunFrequency = "Weekly"
#$schPol.ScheduleRunDays = "Saturday"
#$schPol.IsDailyScheduleEnabled = $false
#$schPol.IsWeeklyScheduleEnabled = $true

#$retPol = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureVM"
#New-AzRecoveryServicesBackupProtectionPolicy -Name "NewPolicy" -WorkloadType "AzureVM" -RetentionPolicy $retPol -SchedulePolicy $schPol -VaultId $recoveryServicesVault.ID

#$pol = Get-AzRecoveryServicesBackupProtectionPolicy -Name "NewPolicy" -VaultId $recoveryServicesVault.ID
#Enable-AzRecoveryServicesBackupProtection -Policy $pol -Name "V2VM" -ResourceGroupName $resourceGroupName -VaultId $recoveryServicesVault.ID



  #1) Create a Recovery Services vault.
  #2) Configure a backup of VM, created at 1st day with automatic backup each Saturday at 00:00 GMT.

  #3) Create Azure File Share.
  #4) Connect new File Share as drive X: to VM, created at 1st day, using Custom script extension.

  #5) Create new role with modify permissions, assign it to resource group with VM and add account epmcourse@outlook.com to it.
  # https://docs.microsoft.com/ru-ru/azure/backup/quick-backup-vm-powershell
