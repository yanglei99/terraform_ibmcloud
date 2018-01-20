ibm_sl_username = ""
ibm_sl_api_key = ""
ibm_bmx_api_key = ""

ibm_sl_domain = "example.com"
ibm_sl_datacenter = "sjc03"

ibm_sl_os_reference_code = "CENTOS_7_64"
ibm_sl_vm_user = "root"

ssh_key_path = "../do-key"
ssh_public_key_path = "../do-key.pub"

cluster_name = "myicp"
install_docker = true
root_passwd = "mypassw0rd"
icp_version = "2.1.0.1"

boot_cores= "8"
boot_memory = "16384"
boot_disk = ["100"]
boot_network = 1000

master_count = 1
master_cores= "4"
master_memory = "8192"
master_disk = ["100"]
master_network = 1000

worker_count = 2
worker_cores= "4"
worker_memory = "8192"
worker_disk = ["100"]
worker_network = 1000

enable_iptables = "true"

icp_admin_password = "myadmin"



