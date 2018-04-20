#!/bin/bash

set -x

## -------
# Write stdout and stderr to scaleCluster.txt file
exec > >(tee "scaleCluster.txt")
exec 2>&1

# Cluster variables
CLUSTER_NAME= # Add Desired Cluster Name
RESOURCE_GROUP=$CLUSTER_NAME
DNS_PREFIX=$CLUSTER_NAME
NODE_COUNT= # Add desired node count
NODE_POOL=agentpool1 #value should match the value in clusterDefinition.json

# Validate that values have been set for required variables
if [ -z "$CLUSTER_NAME" ]
then
      echo "\A required value in scaleCluster.sh is empty!!!!!!!!!!!!!"
      exit 1
fi

## -------
# Import global variables
. ./globalVariables.prod.sh

acs-engine scale --subscription-id $AZURE_SUBSCRIPTION_ID \
    --resource-group $RESOURCE_GROUP  \
    --location $AZURE_LOCATION     \
    --deployment-dir _output/$DNS_PREFIX \
    --new-node-count $NODE_COUNT     \
    --node-pool $NODE_POOL \
    --master-FQDN $DNS_PREFIX.$AZURE_LOCATION.cloudapp.azure.com