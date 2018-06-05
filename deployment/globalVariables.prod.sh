#!/bin/bash

set -e # stop script execution on failure
set -x

## -------
# Global variables for the environment
AZURE_SUBSCRIPTION_ID= # Insert Azure Subscription ID value here
export AZURE_SUBSCRIPTION_ID
AZURE_LOCATION=eastus # Insert Azure Location here (westus, eastus, etc.)
export AZURE_LOCATION
MAX_PROJECT_NAME_LENGTH=12
PROJECT_NAME= # Insert project name here
export PROJECT_NAME 
PUBLIC_DOMAIN_NAME_SUFFIX= # Application and middle tier will be accessible at $PROJECT_NAME.$PUBLIC_DOMAIN_NAME_SUFFIX.trafficmanager.net
export PUBLIC_DOMAIN_NAME_SUFFIX

## -------
# Common Azure resources resource group
COMMON_RESOURCE_GROUP=$PROJECT_NAME-$AZURE_LOCATION-resources
export COMMON_RESOURCE_GROUP

if [ ${#PROJECT_NAME} -ge $MAX_PROJECT_NAME_LENGTH ]; then echo "PROJECT_NAME cannot be longer than $MAX_PROJECT_NAME_LENGTH characters" ; exit 1; fi
if [[ $PROJECT_NAME = *-* ]]; then echo "PROJECT_NAME cannot contain dashes" ; exit 1; fi

## -------
# Validate that values have been set for required variables
if [ -z "$AZURE_SUBSCRIPTION_ID" ] || [ -z "$AZURE_LOCATION" ] || [ -z "$PROJECT_NAME" ]
then
      echo "\A required value in globalVariables.prod.sh is empty!!!!!!!!!!!!!"
      exit 1
fi