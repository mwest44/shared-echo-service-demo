# shared-echo-service-demo

Create two TK clusters:  tkg workload cluster and echo service cluster

Create Supervisor Cluster Create Namespaces

    Create infrastructure-service Namespace
    Create frontend-service Namespace
  
Deploy Infrastructure Service

    kubectl vsphere login --server "servername" --vsphere-username administrator@vsphere.local --insecure-skip-tls-verify
    kubectl config use-context infrastructure-service
    kubectl apply -f create-infrastructure-service.yaml
  
Find Load Balancer IP

    kubectl get svc
  
Deploy frontend-service that will proxy to Infrastructure Service in other namespace.

    kubectl config use-context frontend-service
    vi create-local-proxy-service.yaml
      replace ${Service_cluster_Node_IP} in Endpoints with the External-Ip from Load Balancer Service 
    kubectl apply -f create-local-proxy-service.yaml
  
Test Connectivity between namespaces

    kubectl apply -f create-pod-for-test-shell.yaml
    kubectl exec -it shell
    curl http://echo.frontend-service.svc.cluster.local
    curl http://echo.infrastructure-service.svc.cluster.local will also work because we are in the same cluster.
    
Test Connectivity from Tanzu Kubernetes Cluster

    Create frontend-service namespace on tkg cluster
    
    
        kubectl config use-context tkg
        kubectl create namespace frontend-service
    
    Create frontend-service that will proxy to Infrastructure service in Supervisor Cluster
    
        kubectl apply -f create-local-proxy-service.yaml
        
 Test Connectivity To Supervisor Cluster

    kubectl apply -f create-pod-for-test-shell.yaml
    kubectl exec -it shell
    curl http://echo.frontend-service.svc.cluster.local
        
        
    
    

  
