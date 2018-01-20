# Configure the IBM Cloud Provider
provider "ibm" {
  bluemix_api_key    = "${var.ibm_bmx_api_key}"
  softlayer_username = "${var.ibm_sl_username}"
  softlayer_api_key  = "${var.ibm_sl_api_key}"
}

# Create an IBM Cloud infrastructure SSH key. You can find the SSH key surfaces in the infrastructure console under Devices > Manage > SSH Keys
resource "ibm_compute_ssh_key" "test_key_1" {
  label      = "test_key_1"
  public_key = "${file(var.ssh_public_key_path)}"
}

# Create a virtual server with the SSH key
resource "ibm_compute_vm_instance" "my_server_1" {
  hostname          = "${var.ibm_sl_hostname}"
  domain            = "${var.ibm_sl_domain}"
  ssh_key_ids       = ["${ibm_compute_ssh_key.test_key_1.id}"]
  os_reference_code = "${var.ibm_sl_os_reference_code}"
  datacenter        = "${var.ibm_sl_datacenter}"
  network_speed     = 10
  cores             = 1
  memory            = 1024
}