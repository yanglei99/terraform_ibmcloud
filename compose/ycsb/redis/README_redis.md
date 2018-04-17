
### YCSB-Redis 

#### Run workload


* Upload workload definition into Object Storage(S3) 
* [Sample workload definition](workload-5k-5k.dat)

##### on Kubernetes using kubectl
	
    cd k8s
    
	// TO Load
	kubectl apply -f k8s/ycsb-redis-load.yaml
		
		// To look at logs
		kubectl logs -f  $(kubectl get pods -l name=ycsb-load -o jsonpath='{ .items[0].metadata.name }')	
		
	// TO Run
	kubectl apply -f k8s/ycsb-redis-load.yaml
	
		// To look at logs
		kubectl logs -f  $(kubectl get pods -l name=ycsb-run -o jsonpath='{ .items[0].metadata.name }')
	
	
### Known Issue

* Only verified with [Redis cluster hosted on Kubernetes](k8s/redis.yaml). 
	