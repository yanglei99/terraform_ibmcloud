## Compose Benchmark

Terraform configuration and scripts for provisioning Compose DBaaS, Container service, then run Benchmark (i.e. YCSB) using Terraform.

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


### Known Issue and limitation

* Container cluster worker number (3) is hard-coded in [container.tf](container.tf)
