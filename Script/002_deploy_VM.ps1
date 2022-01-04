New-AzResourceGroupDeployment 
  -Name vm-timurbekirov-deployment 
  -ResourceGroupName timurbekirov-labrg 
  -TemplateUri https://raw.githubusercontent.com/bekirovtimur/azure-course/main/ARM/template.json 
  -TemplateParameterUri https://raw.githubusercontent.com/bekirovtimur/azure-course/main/ARM/parameters.json

