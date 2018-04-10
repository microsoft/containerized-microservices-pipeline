#!/bin/bash

set -x

## -------
# Global variables for the environment
AZURE_SUBSCRIPTION_ID=4bfa739e-0d8c-437e-9302-e3da21c66828
export AZURE_SUBSCRIPTION_ID
AZURE_LOCATION=eastus
export AZURE_LOCATION
PROJECT_NAME=microservices
export PROJECT_NAME 

## -------
# Common Azure resources resource group
COMMON_RESOURCE_GROUP=$PROJECT_NAME-$AZURE_LOCATION-resources
export COMMON_RESOURCE_GROUP
