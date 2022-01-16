$azStorageAccountName = "satimurbekirov"
#$azStorageAccountKey = "" # Access key for storage account
$azContainerName = "timurbekirov-lab-blobs"
$azResourceGroupName = "timurbekirov-lab-rg"
$blobName = "install_iis.ps1"

$connectionContext = (Get-AzStorageAccount -ResourceGroupName $azResourceGroupName -AccountName $azStorageAccountName).Context
# Get a list of containers in a storage account
Get-AzStorageContainer -Name $azContainerName -Context $connectionContext | Select Name
# Get a list of blobs in a container
#Get-AzStorageBlob -Container $azContainerName -Context $connectionContext | Select Name
Get-AzStorageBlob -Container $azContainerName -Context $connectionContext
$blobUri = (Get-AzStorageBlob -blob $blobName -Container $azContainerName -Context $connectionContext).ICloudBlob.uri.AbsoluteUri
Write-Output $blobUri
