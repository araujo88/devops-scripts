# Kubernetes

## Basic commands

`kubectl config get-clusters`

`kubectl cluster-info`

`kubectl get nodes`

`kubectl get pods`

`kubectl get pods --all-namespaces`

`kubectl create namespace webserver`

`kubectl config set-context --current --namespace webserver`

`kubectl run nginx --image nginx`

`kubectl get pods -o wide`

`kubectl delete pod nginx`

`kubectl apply -f deployment.yml`

`kubectl apply -f service.yml`

`kubectl get service`
