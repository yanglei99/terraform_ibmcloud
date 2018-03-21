## DC/OS

Terraform configuration and scripts for provision DC/OS on IBM Cloud, revised from [dcos packet-terraform](https://github.com/dcos/packet-terraform)

* This repo holds [Terraform](https://www.terraform.io/) scripts to create a 1, 3, or 5 master DCOS cluster on the [IBM Cloud](https://www.ibm.com/cloud/), using [IBM Cloud Provider for Terraform](https://github.com/IBM-Cloud/terraform-provider-ibm)

##### Theory of Operation:

This script will start the infrastructure machines (bootstrap and masters),
then collect their IPs to build an installer package on the bootstrap machine
with a static master list. All masters wait for an installation script to be
generated on the localhost, then receive that script. This script, in turn,
pings the bootstrap machine whilst waiting for the web server to come online
and serve the install script itself.

When the install script is generated, the bootstrap completes and un-blocks
the cadre of agent nodes, which are  cut loose to provision metal and
eventually install software.


### Cluster Topology

There are four kinds of node: bootstrap, master, agent, public agent. 
You can use its specific count variable to control the number of nodes of the type.

### Software Components

* Docker are installed on all nodes. 
* Firewall rules are enabled.

#### Verified 

* DCOS: 1.11
* Terraform : 0.11.3
* IBM Cloud Provider for Terraform : 0.7.0

### To use:

* Clone or download repo.

* Generate a `do-key` keypair (with an empty passphrase):

	ssh-keygen -t rsa -P '' -f ./do-key

* Copy [sample.terraform.tfvars](./sample.terraform.tfvars) to `terraform.tfvars` and revise your variables. Reference [vars.tf](./vars.tf) for variable definitions

* Run Provision

    terraform init
	terraform apply

* Change agent count

	terraform apply -var ‘agent_count=N’` 
	
#### Configuration Details

Reference [vars.tf](./vars.tf) for more definitions

| Scenario | Configuration | Default Value | Notes|
|----------|---------------|-------|------|
|Docker Installation | install_docker |false| Default behavior is for CoreOS which already includes docker installation. For other OS, set it to true.|
|Wait Time|wait_time_vm|15| You may need to adjust the value to make sure remote provisioner actions only start after VM is ready.|
|Enable iptable rules|enable_iptables|true| only allow predefined ports on public IP


### Known issues and constraints

* CENTOS hit issue can not ping  DNS Forwarder (ready.spartan). Work-around by provision COREOS
