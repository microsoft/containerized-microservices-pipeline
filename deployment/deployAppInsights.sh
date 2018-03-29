#!/bin/bash

set -x

SUBSCRIPTION_ID="" # Set subscription ID.
CLUSTER_NAME="" # Set Cluster Name.
LOCATION=westus # Specify Location of Cluster.

RESOURCE_GROUP=$CLUSTER_NAME
INSIGHTS_NAME="$CLUSTER_NAME"-app-insights-front-end

az account set -s $SUBSCRIPTION_ID
az resource delete --resource-group $RESOURCE_GROUP --name=$INSIGHTS_NAME --resource-type microsoft.insights/components
az resource create --resource-group $RESOURCE_GROUP --name=$INSIGHTS_NAME --resource-type microsoft.insights/components --properties '{ "kind": "Node.JS", "Application_Type": "Node.JS", "location": "'"$LOCATION"'"}'

echo "Use this key in the application settings for Front End."
az resource show --resource-group $RESOURCE_GROUP --name=$INSIGHTS_NAME --resource-type microsoft.insights/components | grep InstrumentationKey