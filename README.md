shared-echo-service-demo
Create two TK clusters: tkg workload cluster and echo service cluster

Create Supervisor Cluster Create Namespaces

Create infrastructure-service Namespace
Create frontend-service Namespace
Deploy Infrastructure Service

kubectl vsphere login --server "servername" --vsphere-username administrator@vsphere.local --insecure-skip-tls-verify
kubectl config use-context infrastructure-service
kubectl apply -f create-infrastructure-service.yaml
kubectl describe svc echo     (Note the Endpoint for local pod)
Deploy Test pod

kubectl apply -f create-pod-for-test-shell.yaml
Curl the Supervisor Infrastructure Service from the Shell Pod

kubectl exec -it shell -- /bin/bin
curl http://echo.infrastructure-service.svc.cluster.local
Find Load Balancer IP

kubectl get svc     Note this for later
Test Connectivity from Tanzu Kubernetes Cluster to Supervisor Cluster Service

kubectl vsphere login --server k8s.corp.local -u administrator@corp.local --tanzu-kubernetes-cluster-name echo-service-cluster --tanzu-kubernetes-cluster-namespace tkg --insecure-skip-tls-verify

kubectl config use-context echo-service-cluster

Create frontend-service namespace on tkg cluster

    kubectl create namespace frontend-service

Create frontend-service that will proxy to Infrastructure service in Supervisor Cluster
    
    vi create-local-proxy-service.yaml
        replace ${Service_cluster_Node_IP} in Endpoints with the External-Ip from Load Balancer Service 
    kubectl apply -f create-local-proxy-service.yaml
    kubectl describe svc echo -n frontend-service   (Note Endpoint is LB of Infrastructure Service in Supervisor Cluster
Deploy Test Pod and connect to Supervisor Infrastructure Service

kubectl apply -f create-pod-for-test-shell.yaml -n frontend-service
kubectl exec -it shell -n frontend-service -- /bin/bash
curl http://echo.frontend-service.svc.cluster.local
Microservice Application Deployment across Tanzu Kubernetes Cluster and Supervisor Cluster

Data Services will run in vSphere pods directly on ESXi hosts and all frontend services will run in Tanzu Kubernetes Cluster
