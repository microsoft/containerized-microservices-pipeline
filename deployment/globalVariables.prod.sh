#!/bin/bash

set -x

## -------
# Global variables for the environment
AZURE_SUBSCRIPTION_ID=AzureSubscriptionIdGoesHere # Replace value with Azure Subscription ID to use
export AZURE_SUBSCRIPTION_ID
AZURE_LOCATION=westus
export AZURE_LOCATION
PROJECT_NAME=microservices
export PROJECT_NAME 

## -------
# Common Azure resources resource group
COMMON_RESOURCE_GROUP=$PROJECT_NAME-$AZURE_LOCATION-resources
export COMMON_RESOURCE_GROUP