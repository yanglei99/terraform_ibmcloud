
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

variable "ibm_sl_hostname" {
  description = "Softlayer VM Hostname"
  default = "myvm"
}

variable "ibm_sl_datacenter" {
  description = "Softlayer DataCenter"
  default = "mex01"
}

variable "ibm_sl_os_reference_code" {
  description = "Softlayer OS reference code"
  default = "CENTOS_LATEST_64"
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
