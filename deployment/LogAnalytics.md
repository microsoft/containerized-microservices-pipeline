## What is Log Analytics?
Azure Log Analytics allows you to collect and correlate data from multiple sources so you can monitor entire solutions. It helps you get insight across workloads and systems to maintain availability and performance.

## How Log Analytics is used in this solution:
We have employed Azure Log Analytics in order to monitor container health. We outline how to add this solution to your workspace below. The container monitoring solution shows which containers are running, where they are running, and what container image they’re running. Using this solution, we can troubleshoot containers by viewing detailed audit information and by searching centralized logs without having to remotely view Docker hosts. This solution makes it easy to find containers that may be noisy and consuming excess resources on a host. Additionally, you can view centralized CPU, memory, storage, and network usage and performance information.

## Integrating Log Analytics with this project:
In [inception.sh](/deployment/inception.sh), an OMS Workspace is created using the JSON template in the deployment directory.
If you would like to change the location of the workspace, you can choose from East US, West Europe, Australia Southeast, and Southeast Asia.
However, you must change this value both in the creation of the workspace in [inception.sh](/deployment/inception.sh):

```
az storage account create --name $K8_DEPLOYMENT_DIAGSA_NAME --resource-group $COMMON_RESOURCE_GROUP --location eastus --sku Standard_LRS
```
and in [logAnalytics.parameters.json](/deployment/logAnalyticsOms.parameters.json):

```
    "workspaceName": {
      "value": "microservices-eastus-ws"
    },
    "location": {
      "value": "East US"
    },
```
Additionally, the OMS Agent must be installed on the cluster.

## Install OMS Agent onto Cluster
1. Navigate to your OMS Workspace in the portal by finding it under your "Log Analytics" resources
2. Find your Workspace Key by clicking on the Advanced Settings blade, then Connected Sources > Linux Servers
3. Copy the primary key and paste it into line 19 of [installOmsAgent.sh](/deployment/installOmsAgent.sh)
4. Run `installOmsAgent.sh`

## Add solutions to your Log Analytics workspace:
1. In the Azure portal, select Create a resource > Management Tools > See all.
2. In the Management Tools blade, select a management solution that you want to add to a workspace. For the purposes of this project, we recommend the Container Monitoring Solution.
3. In the specific solution blade, review information about the management solution, and then click Create.
4. In the management solution name blade, select a workspace that you want to associate with the management solution.
5. To start using the management solution that you've added to your workspace, navigate to Log Analytics > workspace name > Overview. A new tile for your management solution is displayed. Click the tile to open it and start using the solution after data for the solution is gathered.
