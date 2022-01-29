#/bin/bash

# Variables
resourceGroupName="timurbekirov-webapp-rg"
appName="webapp2048"
location="WestEurope"

# Create a Resource Group
az group create --name $resourceGroupName --location $location

# Create network resources
az network vnet create \
    --resource-group $resourceGroupName \
    --name VirtualNetwork \
    --location $location \
    --address-prefix 10.0.0.0/16 \
    --subnet-name AppGateSubnet \
    --subnet-prefix 10.0.1.0/24

az network public-ip create \
    --resource-group $resourceGroupName --location $location \
    --name AppGatePublicIP --dns-name $appName --sku Standard

# Create an App Service Plan
az appservice plan create --resource-group $resourceGroupName \
    --name myAppServicePlan --location $location --sku S1

# Create a Web App
az webapp create --resource-group $resourceGroupName \
    --name $appName --plan myAppServicePlan

appFqdn=$(az webapp show --name $appName --resource-group $resourceGroupName --query defaultHostName -o tsv)

# Create an Application Gateway
az network application-gateway create \
    --resource-group $resourceGroupName \
    --name WebAppGateway \
    --location $location \
    --vnet-name VirtualNetwork \
    --subnet AppGateSubnet \
    --min-capacity 2 \
    --sku Standard_v2 \
    --http-settings-cookie-based-affinity Disabled \
    --frontend-port 80 \
    --http-settings-port 80 \
    --http-settings-protocol Http \
    --public-ip-address AppGatePublicIP \
    --servers $appFqdn

az network application-gateway http-settings update \
    --resource-group $resourceGroupName --gateway-name WebAppGateway \
    --name appGatewayBackendHttpSettings \
    --host-name-from-backend-pool

# Apply Access Restriction to Web App
az webapp config access-restriction add \
    --resource-group $resourceGroupName --name $appName \
    --priority 200 --rule-name gateway-access \
    --subnet AppGateSubnet --vnet-name VirtualNetwork

# Get the App Gateway Fqdn
az network public-ip show \
    --resource-group $resourceGroupName \
    --name AppGatePublicIP \
    --query {AppGatewayFqdn:dnsSettings.fqdn} \
    --output table

az webapp deployment user set --user-name $appName --password $appName
az webapp deployment source config-local-git --name $appName --resource-group $resourceGroupName
gitAppURL=$(az webapp deployment source config-local-git --name "webapp2048" --resource-group "timurbekirov-webapp-rg" | | jq -r '.url')
