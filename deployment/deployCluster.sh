#!/bin/bash

set -x

CLUSTER_NAME="" # Add Desired Cluster Name
LOCATION="" # Specify Location of Cluster
SUBSCRIPTION_ID="" # Add Azure Subscription ID

TENANT_ID=$(az account show --query tenantId -o tsv)

## -------
## create resource group
RESOURCE_GROUP=$CLUSTER_NAME
az group delete --name=$CLUSTER_NAME --yes
az group create --name=$RESOURCE_GROUP --location=$LOCATION

## -------
## create service principal
SERVICE_PRINCIPAL_NAME=$CLUSTER_NAME
az ad sp delete --id http://$SERVICE_PRINCIPAL_NAME
SERVICE_PRINCIPAL_PASSWORD=`az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$CLUSTER_NAME" --query password -o tsv`

sleep 5 # Azure CLI bug needs delay so SP can propegate

## -------
## create key vault for passing secrets down to the services
KEYVAULT_NAME="$CLUSTER_NAME"-mt-deployment
az keyvault create --name $KEYVAULT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION

SERVICE_PRINCIPAL_APP_ID=`az ad sp list --display-name ${SERVICE_PRINCIPAL_NAME} --query [].appId -o tsv`

# SP running in K8s can only read the secret
az keyvault set-policy --secret-permissions get --resource-group $RESOURCE_GROUP --name $KEYVAULT_NAME --spn http://$SERVICE_PRINCIPAL_NAME

## -------
## create kubernetes cluster
DNS_PREFIX=$CLUSTER_NAME
az acs create --orchestrator-type=kubernetes --generate-ssh-keys --resource-group $RESOURCE_GROUP --name=$CLUSTER_NAME --dns-prefix=$DNS_PREFIX --service-principal http://$SERVICE_PRINCIPAL_NAME --client-secret $SERVICE_PRINCIPAL_PASSWORD --agent-vm-size Standard_DS2_v2 --master-vm-size Standard_DS2_v2 

sleep 5 #  Azure CLI bug needs cluster provisioning to complete before requestion credentials for kubectl

## -------
## Download Kubernetes Credentials
az acs kubernetes get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

## ------
## Kube Version
kubectl version

## ------
## Kube Cluster
kubectl cluster-info

