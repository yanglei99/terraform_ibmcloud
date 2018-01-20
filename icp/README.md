## ICP

Terraform configuration and scripts for provision [IBM Cloud Private (ICP)](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/kc_welcome_containers.html) on IBM Cloud


### Cluster Topology

There are three kinds of nodes: bootstrap, master, worker. 
* Bootstrap node is also master and management node. 
* All master nodes are proxy and management nodes.

You can use its specific count variable to control the number of master and worker nodes.

#### Verified 

On:

* ICP: 2.1.0.1 CE (Kubernetes 1.8.3). Only supports `master_count = 1`

With [Acmeair Micro-Service](https://github.com/yanglei99/acmeair-nodejs/blob/master/document/k8s/acmeair-ms.yaml)

### To use:

* Clone or download repo.

* Copy [sample.terraform.tfvars](./sample.terraform.tfvars) to `terraform.tfvars` and revise your variables.

* Revise [common-config.yaml](install/common-config.yaml) with any additional configuration. IP and password related settings are generated during deployment.

* Run Provision

	terraform apply

	
#### Configuration Details

Reference [vars.tf](./vars.tf) for definitions.

* credentials
* node resources and counts
* iptable enablement
* docker install or not
* ...

To open more ports on public IP, revise [make-files.sh](make-files.sh).

### Known issues and workaround

* Currently, the script only supports ICP CE. 
