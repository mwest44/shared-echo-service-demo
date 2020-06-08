kubectl --context kind-${WORKLOAD_CLUSTER_NAME} exec -it shell \\
    curl http://echo.tkg-system.svc.cluster.local

