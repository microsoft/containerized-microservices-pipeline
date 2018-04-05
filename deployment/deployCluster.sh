#!/bin/bash

set -x

CLUSTER_NAME="" # Add Desired Cluster Name
LOCATION="" # Specify Location of Cluster
SUBSCRIPTION_ID="" # Add Azure Subscription ID

## -------
## create resource group
RESOURCE_GROUP=$CLUSTER_NAME
az group delete --name=$RESOURCE_GROUP --yes
az group create --name=$RESOURCE_GROUP --location=$LOCATION

## -------
## create service principal
ACS_SERVICE_PRINCIPAL_NAME=$CLUSTER_NAME
az ad sp delete --id http://$ACS_SERVICE_PRINCIPAL_NAME
ACS_SERVICE_PRINCIPAL_PASSWORD=`az ad sp create-for-rbac --name $ACS_SERVICE_PRINCIPAL_NAME --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$CLUSTER_NAME" --query password -o tsv`

sleep 5 # Azure CLI bug needs delay so SP can propegate

## -------
## create key vault for passing secrets down to the services
KEYVAULT_NAME="$CLUSTER_NAME"-mt-deployment
az keyvault delete --name $KEYVAULT_NAME --resource-group $RESOURCE_GROUP
az keyvault create --name $KEYVAULT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION

# SP running in K8s can only read the secret
az keyvault set-policy --secret-permissions get --resource-group $RESOURCE_GROUP --name $KEYVAULT_NAME --spn http://$ACS_SERVICE_PRINCIPAL_NAME

## -------
## create kubernetes cluster
DNS_PREFIX=$CLUSTER_NAME
az acs create --orchestrator-type=kubernetes --generate-ssh-keys --resource-group $RESOURCE_GROUP --name=$CLUSTER_NAME --dns-prefix=$DNS_PREFIX --service-principal http://$ACS_SERVICE_PRINCIPAL_NAME --client-secret $ACS_SERVICE_PRINCIPAL_PASSWORD --agent-vm-size Standard_DS2_v2 --master-vm-size Standard_DS2_v2 

sleep 5 #  Azure CLI bug needs cluster provisioning to complete before requestion credentials for kubectl

## -------
## Download Kubernetes Credentials
az acs kubernetes get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

## ------
## Kube Version
kubectl version

## ------
## Kube Cluster
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