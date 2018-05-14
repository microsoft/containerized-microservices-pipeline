#!/bin/bash

set -x

## -------
# Write stdout and stderr to inception.txt file
exec > >(tee "inception.txt")
exec 2>&1

## -------
# Import global variables
. ./globalVariables.prod.sh

## -------
# Login to Azure and set the Azure subscription for this script to use
echo ........ Logging into Azure
az login
az account set --subscription $AZURE_SUBSCRIPTION_ID

## -------
# Make sure DNS name is available for Azure Traffic Manager, if not, exit
if [ az network traffic-manager profile check-dns --name $PROJECT_NAME.$PUBLIC_DOMAIN_NAME_SUFFIX --query nameAvailable = "false" ]; then
    echo "!!!DNS name $PROJECT_NAME is not available in Azure Traffic Manager - exiting!!!"
    exit 1
fi

## -------
# Create the Azure resource group(s) to hold common resources
echo ........ Creating resource groups
az group delete --name=$COMMON_RESOURCE_GROUP --yes
az group create --name $COMMON_RESOURCE_GROUP --location $AZURE_LOCATION

## -------
# Create the Azure Traffic Manager profile
AZURE_TRAFFIC_MANAGER_PROFILE_NAME=$PROJECT_NAME-trafficmgr
az network traffic-manager profile create --name $AZURE_TRAFFIC_MANAGER_PROFILE_NAME --resource-group $COMMON_RESOURCE_GROUP --routing-method Priority --unique-dns-name $PROJECT_NAME.$PUBLIC_DOMAIN_NAME_SUFFIX

## -------
## Create key vault that k8 hexodite will use to get pod specific secrets
K8_DEPLOYMENT_KEYVAULT_NAME=$PROJECT_NAME-deploy-kv
export K8_DEPLOYMENT_KEYVAULT_NAME
az keyvault delete --name $K8_DEPLOYMENT_KEYVAULT_NAME --resource-group $COMMON_RESOURCE_GROUP
az keyvault create --name $K8_DEPLOYMENT_KEYVAULT_NAME --resource-group $COMMON_RESOURCE_GROUP --location $AZURE_LOCATION

## -------
# Create the Azure Container Registry
echo ........ Creating Azure Container Registry
. ./deployContainerRegistry.sh

## -------
## build and push hexadite to ACR
ACR_URL=`az acr show --name $AZURE_CONTAINER_REGISTRY_NAME --query loginServer -o tsv`
ACR_USERNAME=`az acr credential show --name $AZURE_CONTAINER_REGISTRY_NAME --query username -o tsv`
ACR_PASSWORD=`az acr credential show --name $AZURE_CONTAINER_REGISTRY_NAME --query passwords[0].value -o tsv`
git clone https://github.com/Hexadite/acs-keyvault-agent
cd acs-keyvault-agent
docker build . -t ${ACR_URL}/hexadite:latest
docker login -u $ACR_USERNAME -p $ACR_PASSWORD $ACR_URL
docker push ${ACR_URL}/hexadite:latest
cd ..
rm -rf acs-keyvault-agent

## -------
# Create App Insights
echo ........ Creating App Insights
. ./deployAppInsights.sh

## -------
# Create OMS Workspace
echo ........ Creating OMS Workspace
K8_DEPLOYMENT_DIAGSA_NAME="${PROJECT_NAME}diagsa"

# Generate log analytics parameters file
LOG_ANALYTICS_OMS_PARAMS=$(<logAnalyticsOms.parameters.json)
LOG_ANALYTICS_OMS_PARAMS=$(jq --arg workspaceName $PROJECT_NAME-$AZURE_LOCATION-ws '.parameters.workspaceName.value=$workspaceName' <<< "$LOG_ANALYTICS_OMS_PARAMS")
LOG_ANALYTICS_OMS_PARAMS=$(jq --arg storageAccountName $K8_DEPLOYMENT_DIAGSA_NAME '.parameters.applicationDiagnosticsStorageAccountName.value=$storageAccountName' <<< "$LOG_ANALYTICS_OMS_PARAMS")
LOG_ANALYTICS_OMS_PARAMS=$(jq --arg resourceGroup $COMMON_RESOURCE_GROUP '.parameters.applicationDiagnosticsStorageAccountResourceGroup.value=$resourceGroup' <<< "$LOG_ANALYTICS_OMS_PARAMS")
echo $LOG_ANALYTICS_OMS_PARAMS > logAnalyticsOms.parameters.temp.json

az storage account delete --name $K8_DEPLOYMENT_DIAGSA_NAME --resource-group $COMMON_RESOURCE_GROUP --yes
az storage account create --name $K8_DEPLOYMENT_DIAGSA_NAME --resource-group $COMMON_RESOURCE_GROUP --location eastus --sku Standard_LRS
az group deployment delete --resource-group $COMMON_RESOURCE_GROUP --name "Microsoft.LogAnalyticsOMS"
az group deployment create --resource-group $COMMON_RESOURCE_GROUP --name "Microsoft.LogAnalyticsOMS" --template-file logAnalyticsOms.json  --parameters @logAnalyticsOms.parameters.temp.json

rm ./logAnalyticsOms.parameters.temp.json

## -------
# Create the middle tier service
echo ........ Creating middle tier services
. ./createMtSvc.sh

## -------
# Azure resource creation complete, echo values that will be needed for deployCluster.sh
echo ........ "Azure resource deployment complete. All resources deployed to the following resource group."
echo COMMON_RESOURCE_GROUP=$COMMON_RESOURCE_GROUP
echo ........ "Save the following values and use them in deployCluster.sh"
echo K8_DEPLOYMENT_KEYVAULT_NAME=$K8_DEPLOYMENT_KEYVAULT_NAME
echo AZURE_CONTAINER_REGISTRY_NAME=$AZURE_CONTAINER_REGISTRY_NAME
echo AZURE_TRAFFIC_MANAGER_PROFILE_NAME=$AZURE_TRAFFIC_MANAGER_PROFILE_NAME
echo MT_CONNECTION_STRING=$MT_CONNECTION_STRING
