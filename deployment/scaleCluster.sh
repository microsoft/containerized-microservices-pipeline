#!/bin/bash

set -x

## -------
# Write stdout and stderr to scaleCluster.txt file
exec > >(tee "scaleCluster.txt")
exec 2>&1

## -------
# Import global variables
. ./globalVariables.prod.sh

RESOURCE_GROUP=$CLUSTER_NAME
DNS_PREFIX=$CLUSTER_NAME
NODE_COUNT= # Add desired node count

## node-pool value should match the value in clusterDefinition.json
acs-engine scale --subscription-id $AZURE_SUBSCRIPTION_ID \
    --resource-group $RESOURCE_GROUP  \
    --location $AZURE_LOCATION     \
    --deployment-dir _output/$DNS_PREFIX \
    --new-node-count $NODE_COUNT     \
    --node-pool agentpool1 \
    --master-FQDN $DNS_PREFIX.$AZURE_LOCATION.cloudapp.azure.com