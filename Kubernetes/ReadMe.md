# Kubernetes

## Create the app deployment
- Edit line 19 of `app.yaml`. Replace `container-registry` with the right value.
- Run `kubectl create -f app.yaml`.

## Create the service deployment
- Edit line 19 of `service.yaml`. Replace `container-registry` with the right value.
- Run `kubectl create -f service.yaml`.