$tag = @{"owner"="Timur_Bekirov"}

$resourceGroup = Get-AzResourceGroup -Name timurbekirov-lab-rg
New-AzTag -ResourceId $resourceGroup.ResourceId -tag $tag

$resource = Get-AzResource -ResourceGroupName timurbekirov-lab-rg
$resource | ForEach-Object { New-AzTag -Tag $tag -ResourceId $_.ResourceId }
