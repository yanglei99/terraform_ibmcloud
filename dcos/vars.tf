
variable "ibm_sl_username" {
  description = "Your Softlayer user name"
}

variable "ibm_sl_api_key" {
  description = "Your Softlayer API key"
}

variable "ibm_bmx_api_key" {
  description = "Your Platform API key"
}

variable "ibm_sl_domain" {
  description = "Softlayer Domain"
  default = "yl.softlayer.com"
}

variable "ibm_sl_datacenter" {
  description = "Softlayer DataCenter"
  default = "mex01"
}

variable "ibm_sl_os_reference_code" {
  description = "Softlayer OS reference code"
  default = "CENTOS_7_64"
}

variable "ibm_sl_vm_user" {
  description = "VM user"
  default = "root"
}

variable "ssh_key_path" {
  description = "Path to your private SSH key path"
  default = "./do-key"
}

variable "ssh_public_key_path" {
  description = "Path to your public SSH key path"
  default = "./do-key.pub"
}

variable "wait_time_vm" {
  description = "Wait time in second after VM up"
  default = "15"
}

variable "install_docker" {
  description = "Need to install docker or not."
  default = false
}

variable "cluster_name" {
  description = "Cluster name. Used for calculating names like hostname"
  default = "mydcos"
}


variable "boot_cores" {
  description = "Boot VM cores"
  default = "4"
}

variable "boot_memory" {
  description = "Boot VM memory"
  default = "4096"
}

variable "boot_disk" {
  description = "Boot VM disk array"
  type    = "list"
  default = ["100"] 
}

variable "boot_network" {
  description = "Boot VM network"
  default = 1000
}


variable "master_count" {
  description = "Master VM count"
  default = 1
}

variable "master_cores" {
  description = "Master VM cores"
  default = "4"
}

variable "master_memory" {
  description = "Master VM memory"
  default = "4096"
}

variable "master_disk" {
  description = "Master VM disk array"
  type    = "list"
  default = ["100"] 
}

variable "master_network" {
  description = "Master VM network"
  default = 1000
}


variable "agent_count" {
  description = "Agent VM count"
  default = 1
}


variable "public_agent_count" {
  description = "Public agent VM count"
  default = 1
}

variable "agent_cores" {
  description = "Agent VM cores"
  default = "4"
}

variable "agent_memory" {
  description = "Agent VM memory"
  default = "4096"
}

variable "agent_disk" {
  description = "Agent VM disk array"
  type    = "list"
  default = ["100"] 
}

variable "agent_network" {
  description = "Agent VM network"
  default = 1000
}

variable "install_iptables" {
  description = "Enable iptables"
  default = true
}

variable "dcos_installer_url" {
  description = "Path to get DCOS"
  default = "https://downloads.dcos.io/dcos/EarlyAccess/dcos_generate_config.sh"
}

