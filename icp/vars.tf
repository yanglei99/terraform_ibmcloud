
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
  description = "Softlayer OS VM user"
  default = "core"
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
  default = "myicp"
}

variable "root_passwd" {
  description = "Host root password"
}


variable "icp_version" {
  description = "ICP version"
  default = "2.1.0.1"
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


variable "worker_count" {
  description = "Worker VM count"
  default = 1
}

variable "worker_cores" {
  description = "Worker VM cores"
  default = "4"
}

variable "worker_memory" {
  description = "Worker VM memory"
  default = "4096"
}

variable "worker_disk" {
  description = "Worker VM disk array"
  type    = "list"
  default = ["100"] 
}

variable "worker_network" {
  description = "Worker VM network"
  default = 1000
}

variable "enable_iptables" {
  description = "Enable iptables"
  default = "true"
}


variable "icp_admin_password" {
  description = "default admin password"
  default = "admin"
}