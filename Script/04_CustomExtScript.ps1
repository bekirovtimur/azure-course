Set-AzVMCustomScriptExtension `
  -Name 'IIS-Install' `
  -ResourceGroupName 'timurbekirov-lab-rg' `
  -VMName 'vm-timurbekirov-lab' `
  -Run 'install_iis.ps1' `
  -Location 'westeurope' `
  -FileUri "https://satimurbekirov.blob.core.windows.net/timurbekirov-lab-blobs/install_iis.ps1"
