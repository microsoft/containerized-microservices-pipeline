#!/bin/bash

set -x

## -------
# Global variables for the environment
AZURE_SUBSCRIPTION_ID= # Insert Azure Subscription ID value here
export AZURE_SUBSCRIPTION_ID
AZURE_LOCATION=eastus # Insert Azure Location here (westus, eastus, etc.)
export AZURE_LOCATION
PROJECT_NAME= # Insert project name here
export PROJECT_NAME
CLUSTER_NAME= # Add Desired Cluster Name
export CLUSTER_NAME

## -------
# Common Azure resources resource group
COMMON_RESOURCE_GROUP=$PROJECT_NAME-$AZURE_LOCATION-resources
export COMMON_RESOURCE_GROUP

## -------
# Validate that values have been set for required variables
if [ -z "$CLUSTER_NAME" ] || [ -z "$AZURE_SUBSCRIPTION_ID" ] || [ -z "$AZURE_LOCATION" ] || [ -z "$PROJECT_NAME" ]
then
      echo "\A required value in globalVariables.prod.sh is empty!!!!!!!!!!!!!"
      exit 1
fi