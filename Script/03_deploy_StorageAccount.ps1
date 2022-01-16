$resourceGroupName = "timurbekirov-lab-rg"
$templateUri = "https://raw.githubusercontent.com/bekirovtimur/azure-course/main/ARM/StorageAccount/template.json"
$templateParameterUri = "https://raw.githubusercontent.com/bekirovtimur/azure-course/main/ARM/StorageAccount/parameters.json"

Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterUri $templateParameterUri
#New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterUri $templateParameterUri
