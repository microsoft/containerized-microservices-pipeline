#!/bin/bash

set -x

SUBSCRIPTION_ID="" # Set subscription ID.
CLUSTER_NAME="" # Set Cluster Name.
LOCATION=westus # Specify Location of Cluster.

RESOURCE_GROUP=$CLUSTER_NAME
KEYVAULT_NAME="$CLUSTER_NAME"-mt-deployment

SERVICE_PRINCIPAL_NAME=${CLUSTER_NAME}-mt-svc
az ad sp delete --id http://$SERVICE_PRINCIPAL_NAME
SERVICE_PRINCIPAL_PASSWORD=`az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --role=Reader --scopes="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$CLUSTER_NAME" --query password -o tsv`

MT_AAD_PASSWORD_SECRET_NAME=mt-aad-password
az keyvault secret set --name $MT_AAD_PASSWORD_SECRET_NAME --vault-name $KEYVAULT_NAME --description "used by middle tier to access all Azure resources" --value $SERVICE_PRINCIPAL_PASSWORD
