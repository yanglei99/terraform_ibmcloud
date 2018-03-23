resource "ibm_container_cluster" "container_cluster" {

  name         = "${var.container_cluster_name}${random_id.name.hex}"
  datacenter   = "${var.container_cluster_datacenter}"
  org_guid     = "${data.ibm_org.org.id}"
  space_guid   = "${data.ibm_space.space.id}"
  account_guid = "${data.ibm_account.account.id}"
  no_subnet    = true
  subnet_id    = ["${var.container_cluster_subnet_id}"]

  workers = [{
    name   = "worker1"
    action = "add"
    },
    {
      name   = "worker2"
      action = "add"
    },
    {
      name   = "worker3"
      action = "add"
    }
  ]

  machine_type    = "${var.container_cluster_machine_type}"
  isolation       = "${var.container_cluster_isolation}"
  public_vlan_id  = "${var.container_cluster_public_vlan_id}"
  private_vlan_id = "${var.container_cluster_private_vlan_id}"
}


resource "random_id" "name" {
  byte_length = 4
}

output "container_cluster-server_url" {

  value = "${ibm_container_cluster.container_cluster.server_url}"
}

output "container_cluster-worker_num" {

  value = "${ibm_container_cluster.container_cluster.worker_num}"
}