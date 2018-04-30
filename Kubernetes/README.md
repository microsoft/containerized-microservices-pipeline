# Kubernetes

## Connect to your cluster
- Run `az account set --subscription "Your Subscription Name"` to set the proper subscription
- Connect to your cluster by running `az acs kubernetes get-credentials --resource-group=my-resource-group --name=my-k8-cluster`

## Create the app service and deployment
- Run `kubectl create -f app.service.yaml`.
- Edit line 19 of `app.deployment.yaml`. Replace `container-registry` with the value of your container registry.
- Run `kubectl create -f app.deployment.yaml`.

## Create the login-service service, deployment, and horizontal pod autoscaler
- Run `kubectl create -f login-service.service.yaml`.
- Edit line 19 of `login-service.deployment.yaml`. Replace `container-registry` with the value of your container registry.
- Run `kubectl create -f login-service.deployment.yaml`.
- Run `kubectl create -f login-service.horizontalPodAutoscaler.yaml`.

## Deploying Helm Chart
## Install Helm Client (helm)
1. Run ```brew install kubernetes-helm```

[Installation Details for Windows and Linux](https://docs.helm.sh/using_helm/#installing-helm)

## Install Helm Server (Tiller)
1. Run ```helm init```

    This will validate that helm is correctly installed on your local environment and the cluster ```kubectl``` is connected to.
2. Run ```kubectl get pods --namespace kube-system``` to validate tiller is running

```
NAME                                            READY     STATUS    RESTARTS   AGE
...
tiller-deploy-677436516-cq73w                   1/1       Running   0          21h
...
```

## Deploy Ingress Controller (One time per cluster)
1. Run ```helm install stable/traefik --name-template="cluster" --namespace kube-system```

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

## Deploy App Helm Chart onto Cluster
1. Ensure Azure Container Registry Credentials are deployed onto your cluster
2. Run ```helm install ./kubernetes/containerized-microservices-pipeline-app --name canary-containerized-microservices-pipeline-app```

## Deploy Ingress Resource
1. Ensure traefik is already installed on your cluster ```kubectl get pods -n kube-system```
2. Ensure the applications you are using the ingress router names are correctly spelled in the ```values.yaml``` file.
2. Run ```helm install ./kubernetes/ingress-routing```
