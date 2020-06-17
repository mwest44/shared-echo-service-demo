# Shared-echo-service-demo 

git clone https://github.com/mwest44/shared-echo-service-demo.git

 Create Supervisor Cluster Create Namespaces

    tkg for tkg-workload-cluster
    infrastructure-service for backend services
    
 Create TK cluster : tkg-workload-cluster

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
    exit
    
 Find Load Balancer IP

    kubectl get svc     Note this for later
    
 Test Connectivity from Tanzu Kubernetes Cluster to Supervisor Cluster Service

    kubectl vsphere login --server k8s.corp.local -u administrator@corp.local --tanzu-kubernetes-cluster-name tkg-workload-cluster --tanzu-kubernetes-cluster-namespace tkg --insecure-skip-tls-verify

    kubectl config use-context tkg-workload-cluster
    
 Enable RunAsRoot ClusterRole

    kubectl apply -f ~/demo-applications/allow-runasnonroot-clusterrole.yaml

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
    
    
    
# ACMEFit across TK Cluster and Supervisor Cluster Demo

Data Services will run in vSphere pods directly on ESXi hosts and all frontend services will run in Tanzu Kubernetes Cluster


 Create Supervisor Namespace:  distributed-acme-fit

    From vCenter create namespace in Supervisor Cluster
        kubectl vsphere login --server "servername" --vsphere-username administrator@vsphere.local --insecure-skip-tls-verify
        kubectl config use-context distributed-acme-fit
        
 Deploy Data Services onto Supervisor Cluster

    Create Secret for Service to Auth to Redis data cache for cart service
    
	    kubectl create secret generic cart-redis-pass --from-literal=password=VMware1!

    Deploy Redis Cache:

	    cd ~/demo-applications/echo-service
	    kubectl apply -f cart-redis-total.yaml
        
    Create Secret for Service to Auth to Mongo data cache for catalog service
    
	    kubectl create secret generic catalog-mongo-pass --from-literal=password=VMware1!

    Create Configmap to Initialize Mongo DB with catalog Items
    
	    kubectl create -f catalog-db-initdb-configmap.yaml

    Deploy Mongo Instance:
    
	    kubectl apply -f catalog-db-total.yaml
        
    Create Secret for Service to Auth to Orders Postgres DB
    
	    kubectl create secret generic order-postgres-pass --from-literal=password=VMware1!

    Create Postgres DB instance and Order service
    
	    kubectl apply -f order-db-total.yaml
        
    Create Secret for Service to Auth to Users Datastore (Mongo) and Users cach (redis)
    
	    kubectl create secret generic users-mongo-pass --from-literal=password=VMware1!
	    kubectl create secret generic users-redis-pass --from-literal=password=VMware1!

    Create Configmap to Initialize Mongo DB with Initial Set of Users
    
	    kubectl create -f users-db-initdb-configmap.yaml

    Deploy Users Database and Users Service
    
	    kubectl apply -f users-db-total.yaml
	    kubectl apply -f users-redis-total.yaml
	    
Get External IPs for Load Balancer Services

	kubectl get svc     (Note the 5 External-IPs for use in creating Proxy Services on frontend TK cluster)
        
Create Frontend Services in TK Cluster

    kubectl vsphere login --server k8s.corp.local -u administrator@corp.local --tanzu-kubernetes-cluster-name tkg-workload-cluster --tanzu-kubernetes-cluster-namespace tkg --insecure-skip-tls-verify
    
 Create frontend-service namespace and set context on tkg cluster

    kubectl create namespace distributed-acme-fit
    kubectl config set-context --current --namespace=distributed-acme-fit
    kubectl config view --minify | grep ‘namespace: distributed-acme-fit’
    
 Enable RunAsRoot ClusterRole

    kubectl apply -f ~/demo-applications/allow-runasnonroot-clusterrole.yaml
    
Edit Selectorless service YAML files to point endpoints to the corresponding Supervisor Services
 
 	vi	cart-proxy-redis-total.yaml and change IP: field with external IP for cart-redis service in Supervisor
	vi 	catalog-proxy-db-total.yaml and change IP: field with external IP for catalog-mongo service in Supervisor
	vi	order-proxy-db-total.yaml and change IP: field with external IP for order-postgres service in Supervisor
	vi	users-proxy-db-total.yaml and change IP: field with external IP for user-mongo service in Supervisor
	vi	users-proxy-redis-total.yaml and change IP: field with external IP for user-redis service in Supervisor
	
Deploy Frontend Selectorless Proxy services on TK Cluster

	kubectl apply -f cart-proxy-redis-total.yaml
	kubectl apply -f catalog-proxy-db-total.yaml
	kubectl apply -f order-proxy-db-total.yaml
	kubectl apply -f users-proxy-db-total.yaml
	kubectl apply -f users-proxy-redis-total.yaml
	
	Verify Service and Endpoints
		kubectl get svc
		kubectl get endpoints

Deploy Service Pods on TK Cluster

	kubectl apply -f cart-total.yaml
	kubectl apply -f catalog-total.yaml
	kubectl apply -f payment-total.yaml
	kubectl apply -f order-total.yaml
	kubectl apply -f users-total.yaml
	kubectl apply -f frontend-total.yaml
	kubectl apply -f point-of-sales-total.yaml
	
	
Go to Store UserInterface

	kubectl get svc frontend and note the External-IP

From Browser:   http://External-IP

Login as user: eric     password:  vmware1!

 
    
 

 
