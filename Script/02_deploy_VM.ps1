$resourceGroupName = "timurbekirov-lab-rg"
$templateUri = "https://raw.githubusercontent.com/bekirovtimur/azure-course/main/ARM/VM/template.json"
$templateParameterUri = "https://raw.githubusercontent.com/bekirovtimur/azure-course/main/ARM/VM/parameters.json"

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterUri $templateParameterUri
