#!/bin/bash

########################################
# Script assumes it is being executed by inception.sh and the Azure Subscription has been set
# The following global variables need to be defined for this script to run successfully
# COMMON_RESOURCE_GROUP
# AZURE_LOCATION
# PROJECT_NAME
########################################

set -x

AZURE_CONTAINER_REGISTRY_NAME=$PROJECT_NAME$AZURE_LOCATION$RESOURCE_NAME_STRING_AZURE_CONTAINER_REGISTRY
SKU=Basic # Basic, Premium, Standard

## -------
## create acr
az acr delete -n $AZURE_CONTAINER_REGISTRY_NAME
az acr create -n $AZURE_CONTAINER_REGISTRY_NAME -g $COMMON_RESOURCE_GROUP --sku $SKU -l $AZURE_LOCATION --admin-enabled true
export AZURE_CONTAINER_REGISTRY_NAME