# Kubernetes

## Create the app service
- Run `kubectl create -f app.service.yaml`.

## Create the app deployment
- Edit line 19 of `app.deployment.yaml`. Replace `container-registry` with the right value.
- Run `kubectl create -f app.deployment.yaml`.

## Create the login-service service
- Run `kubectl create -f login-service.service.yaml`.

## Create the login-service deployment
- Edit line 19 of `login-service.deployment.yaml`. Replace `container-registry` with the right value.
- Run `kubectl create -f login-service.deployment.yaml`.

## Create the login-service horizontal pod autoscaler
- Run `kubectl create -f login-horizontalPodAutoscaler.yaml`.