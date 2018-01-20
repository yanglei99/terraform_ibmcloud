output "boot-ip-public" {
  value = "${join(",", ibm_compute_vm_instance.icp_bootstrap.*.ipv4_address)}"
}

output "boot-ip-private" {
  value = "${join(",", ibm_compute_vm_instance.icp_bootstrap.*.ipv4_address_private)}"
}

output "worker-ip-public" {
  value = "${join(",", ibm_compute_vm_instance.icp_worker.*.ipv4_address)}"
}

output "worker-ip-private" {
  value = "${join(",", ibm_compute_vm_instance.icp_worker.*.ipv4_address_private)}"
}

output "master-ip-public" {
  value = "${join(",", ibm_compute_vm_instance.icp_bootstrap.*.ipv4_address)},${join(",", ibm_compute_vm_instance.icp_master.*.ipv4_address)}"
}

output "master-ip-private" {
  value = "${join(",", ibm_compute_vm_instance.icp_bootstrap.*.ipv4_address_private)},${join(",", ibm_compute_vm_instance.icp_master.*.ipv4_address_private)}"
}

output "ui" {
  value = "UI URL is https://master_ip:8443 , default username/password is admin/admin"
}