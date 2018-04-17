# Deployment Scripts

## Development Prerequisites

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

#### Install on Windows with PowerShell
```
Install-Script -Name install-kubectl -Scope CurrentUser -Force
install-kubectl.ps1 [-DownloadLocation <path>]
```
### Install ACS Engine
[Download and install ACS Engine](https://github.com/Azure/acs-engine/blob/master/docs/acsengine.md#install)

### Install JQ
[Download and install JQ](https://stedolan.github.io/jq/download/)

## Azure Resource & k8 Cluster Deployment

### Create initial common Azure resources
These resources should only be created one time per subscription and common resources used by all micro-services.

#### Configure environment variables
Open /deployment/globalVariables.sh and enter values for the deployment.

#### Configure SSH keys
- Generate new [SSH keys](https://github.com/Azure/acs-engine/blob/master/docs/ssh.md#ssh-key-generation/) and save it in /deployment as `cluster_rsa.pub` and `cluster_rsa`
- Update `clusterDefinition.json` with the public key contained in `cluster_rsa.pub`. `keyData` must contain the public portion of an SSH key (e.g. 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABA....')




#### Execute inception.sh
Open a bash shell and execute inception.sh
```
cd /deployment
chmod 775 *
./inception.sh
```

Copy the values for the following variables from the inception script output file - inception.txt, you will need these in deployCluster.sh:

```
K8_DEPLOYMENT_KEYVAULT_NAME
AZURE_CONTAINER_REGISTRY_NAME
MT_CONNECTION_STRING
AZURE_TRAFFIC_MANAGER_PROFILE_NAME
```

#### Edit deployCluster.sh
Using the values from the output of inception.sh captured above, fill out the following values:
```
AZURE_CONTAINER_REGISTRY_NAME=
K8_DEPLOYMENT_KEYVAULT_NAME=
AZURE_TRAFFIC_MANAGER_PROFILE_NAME=
```

#### Execute deployCluster.sh
Open a bash shell and execute deployCluster.sh
```
cd /deployment
./deployCluster.sh
```
