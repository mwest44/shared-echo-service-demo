# shared-echo-service-demo

Create two TK clusters:  tkg workload cluster and echo service cluster

Create Supervisor Cluster Create Namespaces

  Create infrastructure-service Namespace
  Create frontend-service Namespace
  
Deploy Infrastructure Service

  kubectl vsphere login --server "servername" --vsphere-username administrator@vsphere.local --insecure-skip-tls-verify
  kubectl config use-context infrastructure-service
  kubectl apply -f create-echo-service.yaml
  
Find Load Balancer IP

  kubectl get svc
  
Deploy frontend-service that will call Infrastructure Service in other namespace.

  kubectl config use-context frontend-service
  vi create-tkg-echo-system-service.yaml
    replace ${Service_cluster_Node_IP} in Endpoints with the External-Ip from Load Balancer Service 
  kubectl apply -f create-tkg-echo-system-service.yaml
  
Test Connectivity
  
