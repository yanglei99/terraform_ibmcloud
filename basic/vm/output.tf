output "ip-public" {
  value = "${join(",", ibm_compute_vm_instance.my_server_1.*.ipv4_address)}"
}

output "ip-private" {
  value = "${join(",", ibm_compute_vm_instance.my_server_1.*.ipv4_address_private)}"
}
