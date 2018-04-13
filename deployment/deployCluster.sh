#!/bin/bash

set -x

## -------
# Write stdout and stderr to deployCluster.txt file
exec > >(tee "deployCluster.txt")
exec 2>&1

## -------
# Cluster variables
CLUSTER_NAME= # Add Desired Cluster Name
AZURE_TRAFFIC_MANAGER_PROFILE_NAME= # Name of the profile of Azure Traffic Manager

## -------
# Values from inception.txt output
AZURE_CONTAINER_REGISTRY_NAME=  # Azure Container Registry Name
K8_DEPLOYMENT_KEYVAULT_NAME= # Name of KeyVault provisioned in createMtSvc.sh

## -------
# Validate that values have been set for required variables
if [ -z "$CLUSTER_NAME" ] || [ -z "$AZURE_TRAFFIC_MANAGER_PROFILE_NAME" ] || [ -z "$AZURE_CONTAINER_REGISTRY_NAME" ]  || [ -z "$K8_DEPLOYMENT_KEYVAULT_NAME" ]
then
      echo "\A required value in deployCluster.sh is empty!!!!!!!!!!!!!"
      exit 1
fi

## -------
# Import global variables
. ./globalVariables.prod.sh

## -------
# Login to Azure and set the Azure subscription for this script to use
echo ........ Logging into Azure
az login
az account set --subscription $AZURE_SUBSCRIPTION_ID

## -------
## create resource group
RESOURCE_GROUP=$CLUSTER_NAME
az group delete --name=$RESOURCE_GROUP --yes
az group create --name=$RESOURCE_GROUP --location=$AZURE_LOCATION

## -------
## create service principal
ACS_SERVICE_PRINCIPAL_NAME=$CLUSTER_NAME
az ad sp delete --id http://$ACS_SERVICE_PRINCIPAL_NAME
ACS_SERVICE_PRINCIPAL_PASSWORD=`az ad sp create-for-rbac --name $ACS_SERVICE_PRINCIPAL_NAME --role="Contributor" --scopes="/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP" --query password -o tsv`

sleep 10 # Azure CLI bug needs delay so SP can propegate

## -------
# Assign the ACS Service Principal the contributor role on the container registry
ACS_SERVICE_PRINCIPAL_ID=$(az ad sp show --id http://$ACS_SERVICE_PRINCIPAL_NAME --query appId --output tsv)
AZURE_CONTAINER_REGISTRY_ID=$(az acr show --name $AZURE_CONTAINER_REGISTRY_NAME --query id --output tsv)
az role assignment create --assignee $ACS_SERVICE_PRINCIPAL_ID --scope $AZURE_CONTAINER_REGISTRY_ID --role contributor

## -------
# SP running in K8s can only read the secret
az keyvault set-policy --secret-permissions get --resource-group $COMMON_RESOURCE_GROUP --name $K8_DEPLOYMENT_KEYVAULT_NAME --spn http://$ACS_SERVICE_PRINCIPAL_NAME

## -------
## create kubernetes cluster
DNS_PREFIX=$CLUSTER_NAME

# prepare the cluster deployment file for ACS Engine
echo Starting update of cluster definition json file
CLUSTER_DEFINITION=$(<clusterDefinition.json)
CLUSTER_DEFINITION=$(jq --arg id $ACS_SERVICE_PRINCIPAL_ID '.properties.servicePrincipalProfile.clientId=$id' <<< "$CLUSTER_DEFINITION")
CLUSTER_DEFINITION=$(jq --arg secret $ACS_SERVICE_PRINCIPAL_PASSWORD '.properties.servicePrincipalProfile.secret=$secret' <<< "$CLUSTER_DEFINITION")
CLUSTER_DEFINITION=$(jq --arg dnsPrefix $DNS_PREFIX '.properties.masterProfile.dnsPrefix=$dnsPrefix' <<< "$CLUSTER_DEFINITION")
echo $CLUSTER_DEFINITION > clusterDefinition.temp.json
echo Updated cluster definition json file

# generate the ARM template
echo Starting generation of ARM template
acs-engine generate ./clusterDefinition.temp.json
echo Completed generation of ARM template

# deploy the ARM template
echo Starting deployment of ARM template
az group deployment create \
    --name acs-engine-cluster \
    --resource-group $RESOURCE_GROUP \
    --template-file ./_output/$DNS_PREFIX/azuredeploy.json \
    --parameters ./_output/$DNS_PREFIX/azuredeploy.parameters.json
echo Completed deployment of ARM template

echo Starting to clean up ARM template resources
rm ./clusterDefinition.temp.json
rm -d -r ./_output
echo Starting to clean up ARM template resources

#echo "sleeping for a few minutes to allow the ACS cluster to finish initializing so we can retrieve k8 credentials"
#sleep 300 #  Azure CLI bug needs cluster provisioning to complete before requesting credentials for kubectl

ACR_URL=`az acr show --name $AZURE_CONTAINER_REGISTRY_NAME --query loginServer -o tsv`
ACS_EMAIL=`az account show --query user.name -o tsv`
ACR_USERNAME=`az acr credential show --name $AZURE_CONTAINER_REGISTRY_NAME --query username -o tsv`
ACR_PASSWORD=`az acr credential show --name $AZURE_CONTAINER_REGISTRY_NAME --query passwords[0].value -o tsv`

kubectl create secret docker-registry acr-credentials --docker-server $ACR_URL --docker-email $ACS_EMAIL --docker-username=$ACS_SERVICE_PRINCIPAL_ID --docker-password $ACS_SERVICE_PRINCIPAL_PASSWORD

## -------
# # build and push hexadite to ACR
git clone https://github.com/Hexadite/acs-keyvault-agent
cd acs-keyvault-agent
docker build . -t ${ACR_URL}/hexadite:latest
docker login -u $ACR_USERNAME -p $ACR_PASSWORD $ACR_URL
docker push ${ACR_URL}/hexadite:latest
cd ..

## -------
## Download Kubernetes Credentials and show cluster information
scp -i ./cluster_rsa azureuser@$DNS_PREFIX.$AZURE_LOCATION.cloudapp.azure.com:.kube/config .
export KUBECONFIG=`pwd`/config
kubectl version
kubectl cluster-info

## ------
## Helm
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
helm init --upgrade

## ------
## Traefik ingress controller
helm install stable/traefik --name traefik-$CLUSTER_NAME --namespace kube-system

## ------
## OMS Agent
WSID=$(az resource show --resource-group loganalyticsrg --resource-type Microsoft.OperationalInsights/workspaces --name containerized-loganalyticsWS | grep customerId | sed -e 's/.*://')
#helm install --name omsagent --set omsagent.secret.wsid=$WSID --set omsagent.secret.key=$KEYVAL stable/msoms
# TODO: populate $KEYVAL parameter

## -------
## create Azure Traffic Manager endpoint for this cluster
AZURE_PUBLIC_IP_FQDN=$(az network public-ip list -g $RESOURCE_GROUP --query "[?dnsSettings.domainNameLabel=='${CLUSTER_NAME}'].dnsSettings.fqdn" -o tsv)
az network traffic-manager endpoint create --name $CLUSTER_NAME --profile-name $AZURE_TRAFFIC_MANAGER_PROFILE_NAME --resource-group $COMMON_RESOURCE_GROUP --type externalEndpoints --target $AZURE_PUBLIC_IP_FQDN --priority 1

## -------
# ACS cluster deployment and setup complete
echo ........ "ACS cluster deployment and setup complete. All resources deployed to the following resource group."
echo RESOURCE_GROUP=$RESOURCE_GROUP
