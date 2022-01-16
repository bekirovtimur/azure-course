Remove-AzResourceGroup `
  -Name "timurbekirov-lab-rg"

Remove-AzKeyVault `
  -VaultName "timurbekirov-lab" `
  -Location "westeurope" `
  -Force `
  -InRemovedState `
  -PassThru
