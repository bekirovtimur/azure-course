$Cont = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -Status Registered -ResourceGroupName timurbekirov-lab-rg
$PI = Get-AzRecoveryServicesBackupItem -Container $Cont[0] -WorkloadType AzureVM 
Disable-AzRecoveryServicesBackupProtection -Item $PI[0]
