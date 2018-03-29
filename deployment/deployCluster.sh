#!/bin/bash

set -x

CLUSTER_NAME="" # Add Desired Cluster Name
LOCATION="" # Specify Location of Cluster


## -------
## create resource group
RESOURCE_GROUP=$CLUSTER_NAME
az group delete --name=$CLUSTER_NAME --yes
az group create --name=$RESOURCE_GROUP --location=$LOCATION

## -------
## create service principal
SUBSCRIPTION_ID="" # Add Azure Subscription ID
SERVICE_PRINCIPAL_NAME=$CLUSTER_NAME
SERVICE_PRINCIPAL_PASSWORD=`date | md5 | head -c10; echo`
az ad sp delete --id http://$SERVICE_PRINCIPAL_NAME
az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$CLUSTER_NAME" --password $SERVICE_PRINCIPAL_PASSWORD -o json

sleep 5 # Azure CLI bug needs delay so SP can propegate

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

