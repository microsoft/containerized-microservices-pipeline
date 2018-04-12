#!/bin/bash
. ./globalVariables.prod.sh
CLUSTER_DEFINITION=$(<clusterDefinition.json)
CLUSTER_DEFINITION=$(jq --arg subscriptionID $AZURE_SUBSCRIPTION_ID '.properties.linuxProfile.servicePrincipalProfile.clientId=$subscriptionID' <<< "$CLUSTER_DEFINITION")
echo $CLUSTER_DEFINITION > new.json