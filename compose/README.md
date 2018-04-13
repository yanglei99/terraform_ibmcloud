## Compose Benchmark

Terraform configuration and scripts for provisioning Compose DBaaS, Container service, and running Benchmark (i.e. YCSB, DBT2).

### Cluster Components

* Compose DBaaS [IBM Cloud Service](https://ibm-cloud.github.io/tf-ibm-docs/v0.7.0/r/service_instance.html)
* Container Service [IBM Cloud Container Service](https://ibm-cloud.github.io/tf-ibm-docs/v0.7.0/r/container_cluster.html)

#### Verified on

* Terraform : 0.11.3
* IBM Cloud Provider for Terraform : 0.7.0


#### To Use:

* Clone or download repo.

* Revise [terraform.tfvars](./terraform.tfvars). 

* Run Provision

	terraform init
	terraform apply


#### Configuration Details

Reference [vars.tf](./vars.tf) for definitions. 


### Run workload

* [YCSB](ycsb/README.md)
* [DBT2](dbt2/README.md)


### QoS

* [Monitoring and Alert through Prometheus](prometheus/README.md) 


### Analytics

* [YCSB: transform raw data in Object Storage(s3) to performance metrics in Cloudant](analytics/ycsb_analytics-s3-cloudant.ipynb)
* [YCSB: using Spark Streaming monitor Object Storage(s3) and transform raw data to performance metrics in Cloudant](analytics/ycsb_analytics-s3-stream-cloudant.ipynb)
* [YCSB: performance report using performance metrics in Cloudant](analytics/ycsb_analytics-report-cloudant.ipynb)

#### Verified through Local pyspark with jupyter

	export PYSPARK_DRIVER_PYTHON=jupyter
	export PYSPARK_DRIVER_PYTHON_OPTS='notebook'
	export SPARK_HOME=YOUR_SPARK_LOCATION
	
	pyspark --packages org.apache.bahir:spark-sql-cloudant_2.11:2.2.0,com.ibm.stocator:stocator:1.0.17

### Known Issue and limitation

* Container cluster worker number (3) is hard-coded in [container.tf](container.tf)
