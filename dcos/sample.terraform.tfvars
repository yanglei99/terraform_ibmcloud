ibm_sl_username = "YOUR USERNAME"
ibm_sl_api_key = "YOUR API KEY"
ibm_bmx_api_key = "YOUR BLUEMIX API KEY"

ibm_sl_domain = "YOUR DOMAIN"
ibm_sl_datacenter = "sjc03"

#ibm_sl_os_reference_code = "CENTOS_7_64"
#ibm_sl_vm_user = "root"
#install_docker = true
#install_iptables = true

ibm_sl_os_reference_code = "COREOS_LATEST_64"
ibm_sl_vm_user = "core"
install_docker = false
install_iptables = false

ssh_key_path = "../do-key"
ssh_public_key_path = "../do-key.pub"

cluster_name = "mydcos"

vm_user = "root"

boot_cores= "8"
boot_memory = "16384"
boot_disk = ["25"]
boot_network = 1000

master_count = 1
master_cores= "4"
master_memory = "8192"
master_disk = ["25"]
master_network = 1000

agent_count = 1
public_agent_count = 1
agent_cores= "4"
agent_memory = "8192"
agent_disk = ["25"]
worker_network = 1000


dcos_installer_url = "https://downloads.dcos.io/dcos/stable/1.11.0/dcos_generate_config.sh"

wait_time_vm=30


