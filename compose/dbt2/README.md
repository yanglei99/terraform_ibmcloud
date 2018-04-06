## DBT2 on IBM Cloud

[DBT2 Benchmark for MySQL](https://dev.mysql.com/downloads/benchmarks.html) automation over Kubernetes on IBM Cloud.

Integrated with Object Storage S3 for results collection.


### Build YCSB Docker Image 

[Dockerfile](Dockerfile)

* DBT2
* [S3FS](https://github.com/s3fs-fuse/s3fs-fuse)

### Run Details

	// TO Load
	kubectl apply -f dbt2-mysql-load.yaml
		
		// To look at logs
		kubectl logs -f  $(kubectl get pods -l name=dbt2-load -o jsonpath='{ .items[0].metadata.name }')	
		
	// TO Run
	kubectl apply -f dbt2-mysql-run.yaml
	
		// To look at logs
		kubectl logs -f  $(kubectl get pods -l name=dbt2-run -o jsonpath='{ .items[0].metadata.name }')
	
	

### Known Issue


