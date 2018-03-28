# Deployment Scripts

## Prerequisites

### Homebrew
[How to install homebrew](https://brew.sh/)

### Install Azure CLI

#### Install on Mac with Homebrew

```
brew install
brew install azure-cli
```

#### Install on Windows

Download and run [AZ Installer](https://aka.ms/InstallAzureCliWindows)

[For more information on installing Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

### Install Kubectl

#### Install on Mac with Homebrew
```
brew install kubectl
```

#### Install on Windows

### Deploy Cluster
1. Set ```CLUSTER_NAME``` to the name of your cluster
2. Get your azure subscription id:
```
  "environmentName": "EnvName",
  "id": "2aXXX-XXXX-XXXX-XXXX-XXXXX", //subscription id
  "isDefault": true,
  "name": "SubName",
  "state": "Enabled",
  "tenantId": "8mXXX-XXXX-XXXXX",
  "user": {
    "name": "me@me.com",
    "type": "user"
  }
}
```
3. Set ```SUBSCRIPTION_ID``` to your subscription id
4. run ```sh deployCluster.sh```

### Deploy Azure Container Registry
1. Set ```CONTAINER_REGISTRY_NAME``` to be your registry name
2. Set ```RESOURCE_GROUP``` to name your resource group
3. (optional) Set ```SKU``` to be the type of ACR you would like to use
4. run ```sh deployContainerRegistry.sh```
