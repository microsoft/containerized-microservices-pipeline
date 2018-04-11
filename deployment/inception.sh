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
# Create the Azure resource group(s) to hold common resources
echo ........ Creating resource groups
az group delete --name=$COMMON_RESOURCE_GROUP --yes
az group create --name $COMMON_RESOURCE_GROUP --location $AZURE_LOCATION

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
# Create OMS Workspace
echo ........ Creating OMS Workspace
K8_DEPLOYMENT_DIAGSA_NAME=projectdiagsaname
az storage account delete --name $K8_DEPLOYMENT_DIAGSA_NAME --resource-group $COMMON_RESOURCE_GROUP --yes
az storage account create --name $K8_DEPLOYMENT_DIAGSA_NAME --resource-group $COMMON_RESOURCE_GROUP --location eastus --sku Standard_LRS
az group deployment delete --resource-group $COMMON_RESOURCE_GROUP --name "Microsoft.LogAnalyticsOMS"
az group deployment create --resource-group $COMMON_RESOURCE_GROUP --name "Microsoft.LogAnalyticsOMS" --template-file logAnalyticsOms.json  --parameters @logAnalyticsOms.parameters.json

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
