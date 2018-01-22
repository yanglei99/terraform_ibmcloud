# Configure the IBM Cloud Provider
provider "ibm" {
  bluemix_api_key    = "${var.ibm_bmx_api_key}"
  softlayer_username = "${var.ibm_sl_username}"
  softlayer_api_key  = "${var.ibm_sl_api_key}"
}

# Create an IBM Cloud infrastructure SSH key. You can find the SSH key surfaces in the infrastructure console under Devices > Manage > SSH Keys
resource "ibm_compute_ssh_key" "mykey" {
  label      = "${var.cluster_name}-key"
  public_key = "${file(var.ssh_public_key_path)}"
}

# Create virtual server with the SSH key

resource "ibm_compute_vm_instance" "icp_bootstrap" {
  hostname          = "${var.cluster_name}-bootstrap"
  domain            = "${var.ibm_sl_domain}"
  ssh_key_ids       = ["${ibm_compute_ssh_key.mykey.id}"]
  os_reference_code = "${var.ibm_sl_os_reference_code}"
  datacenter        = "${var.ibm_sl_datacenter}"
  
  hourly_billing = "true"
  local_disk = "true"

  cores = "${var.boot_cores}"
  memory = "${var.boot_memory}"
  network_speed = "${var.boot_network}"
  disks = "${var.boot_disk}"
  
  tags = [
     "icp-bootstrap",
     "icp-master"
   ]
   
  	provisioner "local-exec" {
	    command = "echo \"${self.ipv4_address_private} ${self.hostname}\" >> hosts.txt"
	}
	  
  	provisioner "local-exec" {
	    command = "echo \"${self.ipv4_address_private}\" >> masters.txt"
	}

  	provisioner "local-exec" {
	    command = "echo \"${self.ipv4_address_private}\" >> managements.txt"
	}

  	provisioner "local-exec" {
	    command = "echo \"${self.ipv4_address_private}\" >> proxys.txt"
	}

  	provisioner "local-exec" {
	    command = "echo \"${self.ipv4_address}\" >> masters_public.txt"
	}

  	provisioner "local-exec" {
	    command = "echo \"${self.ipv4_address}\" >> proxys_public.txt"
	}

    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_vm} && echo done waiting bootstrap VM ready"
    }
   
}


resource "null_resource" "icp_bootstrap_prep" {
    
    depends_on = ["ibm_compute_vm_instance.icp_bootstrap"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${ibm_compute_vm_instance.icp_bootstrap.ipv4_address}"
    }
    
    provisioner "file" {
      source = "./install/prepSystem.sh"
      destination = "/tmp/prepSystem.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/prepSystem.sh  ${var.root_passwd} true > /tmp/prepSystem.log"
	}
}

resource "null_resource" "icp_bootstrap_docker" {
    
    count = "${var.install_docker}"
    depends_on = ["null_resource.icp_bootstrap_prep"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${ibm_compute_vm_instance.icp_bootstrap.ipv4_address}"
    }
    
     provisioner "file" {
      source = "./install/installDocker.sh"
      destination = "/tmp/installDocker.sh"
    }

     provisioner "remote-exec" {
	  inline = "bash /tmp/installDocker.sh > /tmp/installDocker.log"
	}
     
}


resource "ibm_compute_vm_instance" "icp_master" {

  count  = "${var.master_count - 1 }"
  hostname = "${format("${var.cluster_name}-master-%02d", count.index)}"

  domain            = "${var.ibm_sl_domain}"
  ssh_key_ids       = ["${ibm_compute_ssh_key.mykey.id}"]
  os_reference_code = "${var.ibm_sl_os_reference_code}"
  datacenter        = "${var.ibm_sl_datacenter}"
  
  hourly_billing = "true"
  local_disk = "true"

  cores = "${var.master_cores}"
  memory = "${var.master_memory}"
  network_speed = "${var.master_network}"
  disks = "${var.master_disk}"
  
  tags = [
     "icp-master"
   ]
   
  	provisioner "local-exec" {
	    command = "echo \"${self.ipv4_address_private} ${self.hostname}\" >> hosts.txt"
	}
	  
  	provisioner "local-exec" {
	    command = "echo \"${self.ipv4_address_private}\" >> masters.txt"
	}

  	provisioner "local-exec" {
	    command = "echo \"${self.ipv4_address}\" >> masters_public.txt"
	}

  	provisioner "local-exec" {
	    command = "echo \"${self.ipv4_address_private}\" >> proxys.txt"
	}

  	provisioner "local-exec" {
	    command = "echo \"${self.ipv4_address}\" >> proxys_public.txt"
	}

    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_vm} && echo done waiting bootstrap VM ready"
    }
   
}


resource "null_resource" "icp_master_prep" {
    
    count = "${var.master_count - 1}"
    depends_on = ["ibm_compute_vm_instance.icp_master"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(ibm_compute_vm_instance.icp_master.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "./install/prepSystem.sh"
      destination = "/tmp/prepSystem.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/prepSystem.sh ${var.root_passwd} true > /tmp/prepSystem.log"
	}
     
}

resource "null_resource" "icp_master_docker" {
    
    count = "${var.install_docker * (var.master_count - 1)}"
    depends_on = ["null_resource.icp_master_prep"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(ibm_compute_vm_instance.icp_master.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "./install/installDocker.sh"
      destination = "/tmp/installDocker.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/installDocker.sh > /tmp/installDocker.log"
	}
     
}

resource "ibm_compute_vm_instance" "icp_worker" {

  count  = "${var.worker_count}"
  hostname = "${format("${var.cluster_name}-worker-%02d", count.index)}"

  domain            = "${var.ibm_sl_domain}"
  ssh_key_ids       = ["${ibm_compute_ssh_key.mykey.id}"]
  os_reference_code = "${var.ibm_sl_os_reference_code}"
  datacenter        = "${var.ibm_sl_datacenter}"
  
  hourly_billing = "true"
  local_disk = "true"

  cores = "${var.worker_cores}"
  memory = "${var.worker_memory}"
  network_speed = "${var.worker_network}"
  disks = "${var.worker_disk}"
  
  tags = [
     "icp-worker"
   ]
   
  	provisioner "local-exec" {
	    command = "echo \"${self.ipv4_address_private} ${self.hostname}\" >> hosts.txt"
	}
	  
  	provisioner "local-exec" {
	    command = "echo \"${self.ipv4_address_private}\" >> workers.txt"
	}

    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_vm} && echo done waiting bootstrap VM ready"
    }
   
}


resource "null_resource" "icp_worker_prep" {
    
    count = "${var.worker_count}"
    depends_on = ["ibm_compute_vm_instance.icp_worker"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(ibm_compute_vm_instance.icp_worker.*.ipv4_address, count.index)}"
    }
    
   
    provisioner "file" {
      source = "./install/prepSystem.sh"
      destination = "/tmp/prepSystem.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/prepSystem.sh  ${var.root_passwd} > /tmp/prepSystem.log"
	}

}

resource "null_resource" "icp_worker_docker" {
    
    count = "${var.install_docker * var.worker_count}"
    depends_on = ["null_resource.icp_worker_prep"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(ibm_compute_vm_instance.icp_worker.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "./install/installDocker.sh"
      destination = "/tmp/installDocker.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/installDocker.sh > /tmp/installDocker.log"
	}
     
}

resource "null_resource" "icp_deploy" {
    
	depends_on = ["null_resource.icp_bootstrap_docker", "null_resource.icp_master_docker", "null_resource.icp_worker_docker"]

    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${ibm_compute_vm_instance.icp_bootstrap.ipv4_address}"
    }

    provisioner "local-exec" {
      command = "bash ./make-files.sh ${var.icp_version} ${ibm_compute_vm_instance.icp_bootstrap.ipv4_address_private} ${var.enable_iptables} ${var.enable_federation}"
    }
    
    provisioner "file" {
      source = "etc.hosts"
      destination = "/etc/hosts"
    }

    provisioner "file" {
      source = "icp.masters"
      destination = "/tmp/icp.masters"
    }

    provisioner "file" {
      source = "icp.workers"
      destination = "/tmp/icp.workers"
    }

    provisioner "file" {
      source = "icp.managements"
      destination = "/tmp/icp.managements"
    }

    provisioner "file" {
      source = "icp.proxys"
      destination = "/tmp/icp.proxys"
    }

    provisioner "file" {
      source = "icp.proxys_public"
      destination = "/tmp/icp.proxys_public"
    }

    provisioner "file" {
      source = "icp.masters_public"
      destination = "/tmp/icp.masters_public"
    }

    provisioner "file" {
      source = "install/common-config.yaml"
      destination = "/tmp/common-config.yaml"
    }
    
    provisioner "file" {
      source = "do-deploy.sh"
      destination = "/tmp/do-deploy.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/do-deploy.sh ${var.root_passwd} ${var.icp_admin_password}> /tmp/do-deploy.log"
	}

    provisioner "file" {
      source = "do-install-master-management-iptables.sh"
      destination = "/tmp/do-install-master-management-iptables.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/do-install-master-management-iptables.sh > /tmp/enable-iptables.log"
	}

}

resource "null_resource" "icp_master_post_deploy" {
    
    count = "${var.install_docker * (var.master_count - 1)}"
    depends_on = ["null_resource.icp_deploy"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(ibm_compute_vm_instance.icp_master.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "do-install-master-management-iptables.sh"
      destination = "/tmp/do-install-master-management-iptables.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/do-install-master-management-iptables.sh > /tmp/enable-iptables.log"
	}
}


resource "null_resource" "icp_worker_post_deploy" {
    
    count = "${var.install_docker * var.worker_count}"
    depends_on = ["null_resource.icp_deploy"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(ibm_compute_vm_instance.icp_worker.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "do-install-worker-iptables.sh"
      destination = "/tmp/do-install-worker-iptables.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/do-install-worker-iptables.sh > /tmp/enable-iptables.log"
	}  
}
