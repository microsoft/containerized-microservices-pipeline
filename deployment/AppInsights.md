## What is Application Insights?
Application insights allows you to get actionable insights through application performance management and instant analytics. It helps you seamlessly integrate with your DevOps pipeline using Visual Studio Team Services and Github

## How Application Insights is used in this solution:
We have employed Application Insights to collect telemetry on the front end of our application. By default, it records failed requests, browser page load time, and availability. It is also capable of tracking users, sessions, events, and retention. We added additional custom telemetry such as user created, successful login,  failed login, and login service started.

## Deploying Application Insights:
In the `inception.sh` script, `deployAppInsights.sh` is run. In this script, we run the following command, adding application insights to your resource group:

```
az resource create --resource-group $COMMON_RESOURCE_GROUP --name=$INSIGHTS_NAME --resource-type microsoft.insights/components --properties '{ "kind": "Node.JS", "Application_Type": "Node.JS", "location": "'"$AZURE_LOCATION"'"}'
```

The next line in the script will show you the Application Insights Instrumentation Key, which is the information your application needs in order to communicate with the Azure resource.

```
echo "Use this key in the application settings for Front End."
az resource show --resource-group $COMMON_RESOURCE_GROUP --name=$INSIGHTS_NAME --resource-type microsoft.insights/components --query properties.InstrumentationKey -o tsv
```

Then, in [deployment/configs.properties](deployment/configs.properties), fill in this value for application insights key.

When `deployCluster.sh` is run, the configmap will be populated with this value, allowing your code to access it as an environment variable.
