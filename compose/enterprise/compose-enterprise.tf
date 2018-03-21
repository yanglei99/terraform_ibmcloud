
# Get reference to the Compose Enterprise Cluster managed-from

data "ibm_service_instance" "compose-enterprise-instance" {

  name = "${var.service_compose_enterprice_name}"
  space_guid   = "${data.ibm_space.space.id}"
}


resource "ibm_service_instance" "compose-service-instance" {

  name       = "${var.service_instance_name}"
  space_guid = "${data.ibm_space.space.id}"
  service    = "${var.service_name}"
  plan       = "${var.service_plan}"
  
  parameters  = { cluster_service_instance_id= "${data.ibm_service_instance.compose-enterprise-instance.id}", db_version= "${var.service_db_version}" }
}
 
resource "ibm_service_key" "compose-service-instance-service-key" {

  name                  = "compose_service_instance-service-key"
  service_instance_guid = "${ibm_service_instance.compose-service-instance.id}"
}


output "compose_service_instance-credentials" {

  value = "${ibm_service_key.compose-service-instance-service-key.credentials}"

}

output "compose_service_instance-uri" {

  value = "${lookup(ibm_service_key.compose-service-instance-service-key.credentials,"uri")}"

}
