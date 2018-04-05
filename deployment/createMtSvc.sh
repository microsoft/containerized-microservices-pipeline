#!/bin/bash

########################################
# Script assumes it is being executed by inception.sh and the Azure Subscription has been set
# The following global variables need to be defined for this script to run successfully
# COMMON_RESOURCE_GROUP
# AZURE_LOCATION
# AZURE_SUBSCRIPTION_ID
# PROJECT_NAME
########################################

set -x

MT_SERVICE_PRINCIPAL_NAME=$PROJECT_NAME-mt-svc
az ad sp delete --id http://$MT_SERVICE_PRINCIPAL_NAME
MT_SERVICE_PRINCIPAL_PASSWORD=`az ad sp create-for-rbac --name $MT_SERVICE_PRINCIPAL_NAME --role=Reader --scopes="/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$COMMON_RESOURCE_GROUP" --query password -o tsv`

az keyvault secret set --name mt-aad-password --vault-name $K8_DEPLOYMENT_KEYVAULT_NAME --description "used by middle tier to access all Azure resources" --value $MT_SERVICE_PRINCIPAL_PASSWORD

# MT specific secrets
MT_KEYVAULT_NAME=$PROJECT_NAME-mt-svc-kv
az keyvault delete --name $MT_KEYVAULT_NAME --resource-group $COMMON_RESOURCE_GROUP
az keyvault create --name $MT_KEYVAULT_NAME --resource-group $COMMON_RESOURCE_GROUP --location $AZURE_LOCATION

az keyvault set-policy --secret-permissions get --resource-group $COMMON_RESOURCE_GROUP --name $MT_KEYVAULT_NAME --spn http://$MT_SERVICE_PRINCIPAL_NAME

SQL_PASSWORD=SQLPassword # insert the password and uncomment the line below
#az keyvault secret set --name sql-password --vault-name $MT_KEYVAULT_NAME --description "used by middle tier to login to SQL" --value $SQL_PASSWORD

TOKEN_SIGN_KEY=`uuidgen`
az keyvault secret set --name token-sign-key  --vault-name $MT_KEYVAULT_NAME --description "used by middle tier to sign tokens" --value $TOKEN_SIGN_KEY