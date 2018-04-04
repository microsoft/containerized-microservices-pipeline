# Containerizer Microservice Pipeline App

# Install Helm Client (helm)
1. Run ```brew install kubernetes-helm```

[Installation Details for Windows and Linux](https://docs.helm.sh/using_helm/#installing-helm)

# Install Helm Server (Tiller)
1. Run ```helm init```

    This will validate that helm is correctly installed on your local environment and the cluster ```kubectl``` is connected to.
2. Run ```kubectl get pods --namespace kube-system``` to validate tiller is running

```
NAME                                            READY     STATUS    RESTARTS   AGE
...
tiller-deploy-677436516-cq73w                   1/1       Running   0          21h
...
```

# Deploy App Helm Chart onto Cluster
1. Ensure Azure Container Registry Credentials are deployed onto your cluster
2. Run ```helm install ./kubernetes/containerized-microservices-pipeline-app```