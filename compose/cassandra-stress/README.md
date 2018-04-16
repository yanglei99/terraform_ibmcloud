## Cassandra Stress on IBM Cloud

[Cassandra Stress Benchmark](https://docs.datastax.com/en/cassandra/3.0/cassandra/tools/toolsCStress.html) automation over Kubernetes on IBM Cloud.

Integrated with Object Storage S3 for results collection.


### Build Cassandra-Stress Docker Image 

[Dockerfile](Dockerfile)

* Cassandra (with Cassandra Stress)
* [S3FS](https://github.com/s3fs-fuse/s3fs-fuse)

### Run Details

	// Get the Pod IP and revise the yaml files
	
	kubectl get pod scylladb-scylladb-0 --template={{.status.podIP}} -n scylladb
	kubectl get pod scylladb-scylladb-1 --template={{.status.podIP}} -n scylladb
	kubectl get pod scylladb-scylladb-2 --template={{.status.podIP}} -n scylladb

	// Write Workload
	kubectl apply -f k8s/cassandra-stress-write.yaml -n scylladb

	// Read Workload
	kubectl apply -f k8s/cassandra-stress-read.yaml -n scylladb
		
	// Mix Workload
	kubectl apply -f k8s/cassandra-stress-mix.yaml -n scylladb

	// To look at logs
	kubectl logs -f  $(kubectl get pods -l name=cs-run -o jsonpath='{ .items[0].metadata.name }' -n scylladb) -n scylladb
		
	// To remove the workload
	kubectl delete rc/cs-run-controller -n scylladb
	

### Known Issue


