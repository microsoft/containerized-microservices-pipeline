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

az keyvault secret set --name mt-aad-password --vault-name $K8_DEPLOYMENT_KEYVAULT_NAME --description "used by middle tier to access all Azure resources" --value $MT_SERVICE_PRINCIPAL_PASSWORD --query id

# MT specific secrets
MT_KEYVAULT_NAME=$PROJECT_NAME-mt-svc-kv
az keyvault delete --name $MT_KEYVAULT_NAME --resource-group $COMMON_RESOURCE_GROUP
az keyvault create --name $MT_KEYVAULT_NAME --resource-group $COMMON_RESOURCE_GROUP --location $AZURE_LOCATION

az keyvault set-policy --secret-permissions get --resource-group $COMMON_RESOURCE_GROUP --name $MT_KEYVAULT_NAME --spn http://$MT_SERVICE_PRINCIPAL_NAME

# create SQL DB
SQL_ADMIN=$PROJECT_NAME-sql-admin
SQL_ADMIN_PASSWORD=`uuidgen`
SQL_SERVER_NAME=$PROJECT_NAME
UUID=$(uuidgen)
SQL_DB_NAME=$PROJECT_NAME-$UUID-mt

az sql server create --admin-password $SQL_ADMIN_PASSWORD  --admin-user $SQL_ADMIN --location $AZURE_LOCATION --name $SQL_SERVER_NAME --resource-group $COMMON_RESOURCE_GROUP
az sql db create --name $SQL_DB_NAME --resource-group $COMMON_RESOURCE_GROUP --server $SQL_SERVER_NAME
az sql server firewall-rule create --resource-group $COMMON_RESOURCE_GROUP --server $SQL_SERVER_NAME -n whitelist-internal-azure --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

az keyvault secret set --name sql-password --vault-name $MT_KEYVAULT_NAME --description "used by middle tier to login to SQL" --value $SQL_ADMIN_PASSWORD --query id

MT_CONNECTION_STRING=`az sql db show-connection-string --client ado.net --auth-type SqlPassword --name $SQL_DB_NAME --server $SQL_SERVER_NAME`
MT_CONNECTION_STRING=${MT_CONNECTION_STRING/<username>/$SQL_ADMIN}
export MT_CONNECTION_STRING

# create token signing key
TOKEN_SIGN_KEY=`uuidgen`
az keyvault secret set --name token-sign-key  --vault-name $MT_KEYVAULT_NAME --description "used by middle tier to sign tokens" --value $TOKEN_SIGN_KEY --query id

# use self signed cert for now
SSL_PASSWORD=`uuidgen`
FQDN=`az network traffic-manager profile list --resource-group $COMMON_RESOURCE_GROUP --query [0].dnsConfig.fqdn -o tsv`
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.crt -days 365 -subj "/C=US/ST=Washington/L=Redmond/O=Acme/OU=Org/CN=${FQDN}" -passout env:SSL_PASSWORD
openssl pkcs12 -export -in cert.crt -inkey key.pem -passin env:SSL_PASSWORD -out cert.pfx -passout env:SSL_PASSWORD
az keyvault certificate import --name mt-ssl-cert --vault-name $K8_DEPLOYMENT_KEYVAULT_NAME -f cert.pfx --password $SSL_PASSWORD --query id
 
