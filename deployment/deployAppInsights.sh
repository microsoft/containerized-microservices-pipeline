#!/bin/bash

########################################
# Script assumes it is being executed by inception.sh and the Azure Subscription has been set
# The following global variables need to be defined for this script to run successfully
# COMMON_RESOURCE_GROUP
# AZURE_LOCATION
# PROJECT_NAME
########################################

set -x

INSIGHTS_NAME="$PROJECT_NAME"-app-insights

az resource delete --resource-group $COMMON_RESOURCE_GROUP --name=$INSIGHTS_NAME --resource-type microsoft.insights/components
az resource create --resource-group $COMMON_RESOURCE_GROUP --name=$INSIGHTS_NAME --resource-type microsoft.insights/components --properties '{ "kind": "Node.JS", "Application_Type": "Node.JS", "location": "'"$AZURE_LOCATION"'"}'

echo "Use this key in the application settings for Front End."
az resource show --resource-group $COMMON_RESOURCE_GROUP --name=$INSIGHTS_NAME --resource-type microsoft.insights/components --query properties.InstrumentationKey -o tsv