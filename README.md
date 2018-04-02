# terraform_ibmcloud

[Terraform IBM Provider](https://github.com/IBM-Cloud/terraform-provider-ibm)


## Notes on environment setup

Download Terraform binary and set onto PATH

Download Terraform IBM Provider release binary and enable it in `~/.terraformrc`. Make sure the binary is executable. 

	providers {
    	ibm = “/.../terraform-provider-ibm"
	}

Generate a `do-key` keypair (with an empty passphrase):

	ssh-keygen -t rsa -P '' -f ./do-key
	
## Scenarios

### Basic Scenario

* [VM Instance](basic/vm/basic.tf). 

### Data Center Platform

* [ICP, IBM Cloud Private](icp/README.md). 
* [Mesosphere DC/OS](dcos/README.md). 

### Other Scenarios

* [Compose DBaaS, Container Service and Benchmarking](compose/README.md). 

### Useful Terraform Command

	terraform plan
	terraform graph
	
	terraform apply
	terraform show
	
	terraform plan --destroy
	terraform destroy

