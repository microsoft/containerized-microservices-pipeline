Note: This document is meant to serve as a quick introduction to acs-engine. Executing *deployCluster.sh* does everything mentioned here.

# What is acs-engine?
Azure Container Service (ACS) uses acs-engine (Azure Container Service Engine) to create clusters. acs-engine is an open source, cross-platform tool developed and maintained by Microsoft. It is used to generate ARM templates and ARM parameters which in turn provision Docker enabled clusters managed by one of the many orchestration engines (such as Kubernetes, DC/OS, etc). 

From the acs-engine Github repository:
>The Azure Container Service Engine (acs-engine) generates ARM (Azure Resource Manager) templates for Docker enabled clusters on Microsoft Azure with your choice of DC/OS, Kubernetes, Swarm Mode, or Swarm orchestrators. 

## Download and install
1. Download the correct installation file from the project [release page](https://github.com/Azure/acs-engine/releases) on Github. 
2. Extract the binary file and copy it to a folder that is part of `PATH`.
    - On Windows: `echo %path%`
    - On Linux and MacOS: `echo $PATH`
3. Execute `acs-engine version` in a terminal window to see if acs-engine is installed properly.

## Customize cluster options
The cluster definition json file is provided as input to acs-engine and is used to customize and fine tune the cluster that gets created on Azure. Listed below is a skeletal cluster definition used to create a Kubernetes cluster with 1 master/3 nodes.
- orchestratorType: Specifies the orchestrator type for the cluster.
- dnsPrefix: The dns prefix for the master FQDN. The master FQDN is used for SSH or commandline access.
- vmsize: The size of the VMs. You need at least 2 cores and 100GB disk space. Complete list [here](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-sizes/).
- adminUsername: The username to be used on all linux clusters.
- keyData: The public SSH key used for authenticating access to all Linux nodes in the cluster.
- servicePrincipalProfile: Azure Service credentials to be used by the cluster for self-configuration.

 ```json
{
  "apiVersion": "vlabs",
  "properties": {
    "orchestratorProfile": {
      "orchestratorType": "Kubernetes"
    },
    "masterProfile": {
      "count": 1,
      "dnsPrefix": "[dns-prefix]",
      "vmSize": "Standard_D2_v2"
    },
    "agentPoolProfiles": [
      {
        "name": "agentpool1",
        "count": 2,
        "vmSize": "Standard_D2_v2",
        "availabilityProfile": "AvailabilitySet"
      }
    ],
    "linuxProfile": {
      "adminUsername": "azureuser",
      "ssh": {
        "publicKeys": [
          {
            "keyData": "[public-key]"
          }
        ]
      }
    },
    "servicePrincipalProfile": {
      "clientId": "[app-id]",
      "secret": "[app-secret]"
    }
  }
}
 ```

 More documentation on all the various options available for the cluster definition can be found [here](https://github.com/Azure/acs-engine/blob/master/docs/clusterdefinition.md).

## Using acs-engine
1. Update the cluster definition json file. In the examples listed below we will assume that the file is named `clusterDefinition.json`.
    - Replace [dns-prefix] with the prefix for the hostname.
    - Replace [public-key] with the public key (example: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABA....") you want to use. Check this [link](https://github.com/Azure/acs-engine/blob/master/docs/ssh.md#ssh-key-generation/) if you need help with generating SSH keys.
2. Invoke acs-engine to generate the ARM template files: `acs-engine generate ./clusterDefinition.json`.
    - This will generate a folder called `_output` and put the all generated ARM template files in a folder named after the `dns-prefix` from `clusterDefinition.json`.
3. Use Azure CLI or Powershell to deploy the generated template. In he example listed below replace [dns-prefix] with the value from `clusterDefinition.json` and [resource-group-name] with the right value.
```
    az group deployment create \
    --name acs-engine-create \
    --resource-group [resource-group-name] \
    --template-file ./_output/[dns-prefix]/azuredeploy.json \
    --parameters ./_output/[dns-prefix]/azuredeploy.parameters.json
```