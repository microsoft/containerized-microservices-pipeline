#!/bin/bash

set -x

CONTAINER_REGISTRY_NAME=""
LOCATION=westus

SUBSCRIPTION_ID=""

## -------
## set subscription
az account set -s $SUBSCRIPTION_ID

## -------
## create resource group
RESOURCE_GROUP=""
az group delete --name=$RESOURCE_GROUP --yes
az group create --name=$RESOURCE_GROUP --location=$LOCATION

## -------
## create acr
SKU="Standard" # Basic, Classic, Premium, Standard
az acr create -n $CONTAINER_REGISTRY_NAME -g $RESOURCE_GROUP --sku $SKU -l $LOCATION