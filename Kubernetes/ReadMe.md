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
- Run `kubectl create -f login-horizontalPodAutoscaler.yaml`.
