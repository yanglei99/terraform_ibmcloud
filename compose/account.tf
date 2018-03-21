# Configure the IBM Cloud API Key
provider "ibm" {
  bluemix_api_key    = "${var.ibm_bmx_api_key}"
  softlayer_username = "${var.ibm_sl_username}"
  softlayer_api_key  = "${var.ibm_sl_api_key}"
  region             = "${var.ibm_region}"
}

# Configure the IBM Cloud Org and Space


data "ibm_org" "org" {
  org = "${var.org_name}"
}

data "ibm_space" "space" {
  space = "${var.space_name}"
  org   = "${var.org_name}"
}

data "ibm_account" "account" {
  org_guid = "${data.ibm_org.org.id}"
}
