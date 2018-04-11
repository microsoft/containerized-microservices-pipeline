#!/bin/bash

set -x

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
if [ az network traffic-manager profile check-dns --name micro-service --query nameAvailable = "false" ]; then
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
az network traffic-manager profile create --name $AZURE_TRAFFIC_MANAGER_PROFILE_NAME --resource-group $COMMON_RESOURCE_GROUP --routing-method Priority --unique-dns-name $PROJECT_NAME

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
# Create the Azure SQL Database
# TODO

## -------
# Create App Insights
echo ........ Creating App Insights
. ./deployAppInsights.sh

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
echo AZURE_CONTAINER_REGISTRY_ID=$AZURE_CONTAINER_REGISTRY_ID
echo AZURE_TRAFFIC_MANAGER_PROFILE_NAME=$AZURE_TRAFFIC_MANAGER_PROFILE_NAME