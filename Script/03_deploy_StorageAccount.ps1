##Create storage account
$StorageHT = @{
  ResourceGroupName = 'timurbekirov-lab-rg'
  Name              = 'satimurbekirov'
  SkuName           = 'Standard_LRS'
  Location          = 'westeurope'
}
$StorageAccount = New-AzStorageAccount @StorageHT
$ctx = $StorageAccount.Context

Write-Output "Context is " $ctx
Write-Output "storage account " $StorageAccount

##Create blob container
$containerName = "timurbekirov-lab-blobs"
New-AzStorageContainer -Name $containerName -Context $ctx -Permission blob

##Upload script to blob container
Set-AzStorageBlobContent -File "install_iis.ps1" `
  -Container $containerName `
  -Blob "install_iis.ps1" `
  -Context $ctx `
  -StandardBlobTier Cool
##  StandardBlobTier can be Cool, Hot or Archive

##Get contents
Get-AzStorageBlob -Container $ContainerName -Context $ctx | select Name

##Download blob
#Get-AzStorageBlobContent -Blob "Image001.jpg" `
#  -Container $containerName `
#  -Destination "D:\_TestImages\Downloads\" `
#  -Context $ctx
