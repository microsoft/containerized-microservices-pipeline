# Kubernetes

## Create the app service and deployment
- Run `kubectl create -f app.service.yaml`.
- Edit line 19 of `app.deployment.yaml`. Replace `container-registry` with the right value.
- Run `kubectl create -f app.deployment.yaml`.

### Create the login-service service, deployment, and horizontal pod autoscaler
- Run `kubectl create -f login-service.service.yaml`.
- Edit line 19 of `login-service.deployment.yaml`. Replace `container-registry` with the right value.
- Run `kubectl create -f login-service.deployment.yaml`.
- Run `kubectl create -f login-horizontalPodAutoscaler.yaml`.