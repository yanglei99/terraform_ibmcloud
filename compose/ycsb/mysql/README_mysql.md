
### YCSB-MySQL 

#### Create Database and Table 

	docker run -it --rm mysql mysql -h YOUR_MYSQL_HOST_IP -u root -p
	
		# For Compose DBaaS
		docker run -it --rm mysql $compose_service_instance-uri_cli
		
	mysql> create database ycsb;
	mysql> use ycsb;
	mysql> CREATE TABLE usertable (
           YCSB_KEY VARCHAR(255) PRIMARY KEY,
           FIELD0 TEXT, FIELD1 TEXT,
           FIELD2 TEXT, FIELD3 TEXT,
           FIELD4 TEXT, FIELD5 TEXT,
           FIELD6 TEXT, FIELD7 TEXT,
           FIELD8 TEXT, FIELD9 TEXT
       );
	mysql> show tables;
	

#### Run workload


* Upload workload definition into Object Storage(S3) 
* Upload mysql-connector-java jar into Object Storage(S3)
* [Sample workload definition](workload-2-5k-5k.dat)

##### on Mesosphere DC/OS

Revise workload [json files](./marathon) with the right content

    cd marathon
    
	// TO Load
	curl -i -H 'Content-Type: application/json' -d@ycsb-mysql-load.json $marathonIp:8080/v2/apps
		
	// TO Run
	curl -i -H 'Content-Type: application/json' -d@ycsb-mysql-run.json $marathonIp:8080/v2/apps

##### on Kubernetes using kubectl
	
    cd k8s
    
	// TO Load
	kubectl apply -f ycsb-mysql-load.yaml
		
		// To look at logs
		kubectl logs -f  $(kubectl get pods -l name=ycsb-load -o jsonpath='{ .items[0].metadata.name }')	
		
	// TO Run
	kubectl apply -f ycsb-mysql-load.yaml
	
		// To look at logs
		kubectl logs -f  $(kubectl get pods -l name=ycsb-run -o jsonpath='{ .items[0].metadata.name }')
	
	

##### on Kubernetes using helm chart

[helm chart](k8s/chart)
	
### Known Issue
	