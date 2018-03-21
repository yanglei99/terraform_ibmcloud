output "agent-ip-public" {
  value = "${join(",", ibm_compute_vm_instance.dcos_agent.*.ipv4_address)}"
}

output "agent-ip-private" {
  value = "${join(",", ibm_compute_vm_instance.dcos_agent.*.ipv4_address_private)}"
}

output "public-agent-ip-public" {
  value = "${join(",", ibm_compute_vm_instance.dcos_public_agent.*.ipv4_address)}"
}

output "public-agent-ip-private" {
  value = "${join(",", ibm_compute_vm_instance.dcos_public_agent.*.ipv4_address_private)}"
}

output "master-ip-private" {
  value = "${join(",", ibm_compute_vm_instance.dcos_master.*.ipv4_address_private)}"
}

output "master-ip-public" {
  value = "${join(",", ibm_compute_vm_instance.dcos_master.*.ipv4_address)}"
}

output "bootstrap-ip" {
  value = "${ibm_compute_vm_instance.dcos_bootstrap.ipv4_address}"
}

output "The link to access DCOS" {
  value = "http://${ibm_compute_vm_instance.dcos_master.0.ipv4_address}/"
}
