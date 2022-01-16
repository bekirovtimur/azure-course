Remove-AzResourceGroup `
  -Name "timurbekirov-lab-rg"

Remove-AzKeyVault `
  -VaultName "timurbekirov-lab" `
  -Force `
  -InRemovedState `
  -PassThru
