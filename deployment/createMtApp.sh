#!/bin/bash

set -x

SUBSCRIPTION_ID="" # Set subscription ID.
CLUSTER_NAME="" # Set Cluster Name.
LOCATION=westus # Specify Location of Cluster.

RESOURCE_GROUP=$CLUSTER_NAME
DEPLOYMENT_KEYVAULT_NAME="$CLUSTER_NAME"-mt-deployment

MT_SERVICE_PRINCIPAL_NAME=${CLUSTER_NAME}-mt-svc
az ad sp delete --id http://$MT_SERVICE_PRINCIPAL_NAME
MT_SERVICE_PRINCIPAL_PASSWORD=`az ad sp create-for-rbac --name $MT_SERVICE_PRINCIPAL_NAME --role=Reader --scopes="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$CLUSTER_NAME" --query password -o tsv`

az keyvault secret set --name mt-aad-password --vault-name $DEPLOYMENT_KEYVAULT_NAME --description "used by middle tier to access all Azure resources" --value $MT_SERVICE_PRINCIPAL_PASSWORD

# MT specific secrets
MT_KEYVAULT_NAME="$CLUSTER_NAME"-mt-svc
az keyvault delete --name $MT_KEYVAULT_NAME --resource-group $RESOURCE_GROUP
az keyvault create --name $MT_KEYVAULT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION

az keyvault set-policy --secret-permissions get --resource-group $RESOURCE_GROUP --name $MT_KEYVAULT_NAME --spn http://$MT_SERVICE_PRINCIPAL_NAME

SQL_PASSWORD=<SQL password> # insert the password and uncomment the line below
#az keyvault secret set --name sql-password --vault-name $MT_KEYVAULT_NAME --description "used by middle tier to login to SQL" --value $SQL_PASSWORD

TOKEN_SIGN_KEY=`uuidgen`
az keyvault secret set --name token-sign-key  --vault-name $MT_KEYVAULT_NAME --description "used by middle tier to sign tokens" --value $TOKEN_SIGN_KEY