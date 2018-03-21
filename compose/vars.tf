
variable "ibm_sl_username" {
  description = "Your Softlayer user name"
}

variable "ibm_sl_api_key" {
  description = "Your Softlayer API key"
}

variable "ibm_bmx_api_key" {
  description = "Your Platform API key"
}

variable "ibm_region" {
  description = "Your Region"
}

variable "org_name" {
  description = "The CF Org name needed for Compose"
}

variable "space_name" {
  description = "The CF Space name needed for Compose"
}

variable "service_instance_name" {
  description = "The service instance name"
}

variable "service_name" {
  description = "The service name"
}

variable "service_plan" {
  description = "The service name"
  default = "Standard"
}

variable "service_compose_enterprice_name" {
  description = "The service compose enterprise name. It is used to retrieve the ID. "
  default = "compose-enterprise"
}

variable "service_db_version" {
  description = "The service DB version"
  default = ""
}


variable "container_cluster_name" {
  description = "The container cluster name"
}

variable "container_cluster_datacenter" {
  description = "The container cluster datacenter"
  default = "dal10"
}


variable "container_cluster_machine_type" {
  description = "The container cluster machine type"
  default = "u2c.2x4"
}

variable "container_cluster_subnet_id" {
  description = "The container cluster subnet id"
  default = []
}

variable "container_cluster_isolation" {
  description = "The container cluster isolation"
  default = "public"
}

variable "container_cluster_public_vlan_id" {
  description = "The container cluster public vlan id"
  default = ""
}

variable "container_cluster_private_vlan_id" {
  description = "The container cluster private vlan id"
  default = ""
}

