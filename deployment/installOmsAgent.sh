#!/bin/bash

set -e # stop script execution on failure
set -x

## -------
# Write stdout and stderr to installOmsAgent.txt file
exec > >(tee "installOmsAgent.txt")
exec 2>&1

## -------
# Import global variables
. ./globalVariables.prod.sh

## -------
# Specify OMS Workspace Key:
# Navigate to your OMS Workspace in the portal by finding it under your "Log Analytics" resources
# Find your Workspace Key by clicking on the Advanced Settings blade, then Connected Sources > Linux Servers > Primary Key
OMS_WORKSPACE_KEY= # Workspace Key associated with your OMS Workspace

## ------
## OMS Agent
WSID=$(az resource show --resource-group $COMMON_RESOURCE_GROUP --resource-type Microsoft.OperationalInsights/workspaces --name $PROJECT_NAME-$AZURE_LOCATION-ws | grep customerId | sed -e 's/.*://')
helm install --name omsagent --set omsagent.secret.wsid=$WSID --set omsagent.secret.key=$OMS_WORKSPACE_KEY stable/msoms --namespace kube-system