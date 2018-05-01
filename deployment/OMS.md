## What is log analytics?
Azure Log Analytics allows you to collect and correlate data from multiple sources so you can monitor entire solutions. It helps you get insight across workloads and systems to maintain availability and performance.

## Integrating Log Analytics with your Solution:
In "inception.sh", an OMS Workspace is created using the JSON template in the deployment directory.
If you would like to change the location of the workspace, you can choose from East US, West Europe, Australia Southeast, and Southeast Asia.
However, you must change this value both in the creation of the workspace in inception.sh

```
az storage account create --name $K8_DEPLOYMENT_DIAGSA_NAME --resource-group $COMMON_RESOURCE_GROUP --location eastus --sku Standard_LRS
```
and in loganalytics.parameters.json

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
3. Copy the primary key and paste it into the helm command in step 5
4. Open a terminal and run this command to find the Workspace ID:

```
WSID=$(az resource show --resource-group resourcegroupname  --resource-type Microsoft.OperationalInsights/workspaces --name loganalyticsworkspacename | grep customerId | sed -e 's/.*://')
```
5. Run the following with your proper Workspace Key:

```
#helm install --name omsagent --set omsagent.secret.wsid=$WSID --set omsagent.secret.key=<key-value> stable/msoms
```
