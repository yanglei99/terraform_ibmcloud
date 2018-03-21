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

resource "ibm_compute_vm_instance" "dcos_bootstrap" {

  hostname          = "${var.cluster_name}-bootstrap"
  domain            = "${var.ibm_sl_domain}"
  ssh_key_ids       = ["${ibm_compute_ssh_key.mykey.id}"]
  os_reference_code = "${var.ibm_sl_os_reference_code}"
  datacenter        = "${var.ibm_sl_datacenter}"
  
  user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.ssh_public_key_path}")}\"\n"

  hourly_billing = "true"
  local_disk = "true"

  cores = "${var.boot_cores}"
  memory = "${var.boot_memory}"
  network_speed = "${var.boot_network}"
  disks = "${var.boot_disk}"

	provisioner "local-exec" {
	    command = "echo BOOTSTRAP=\"${ibm_compute_vm_instance.dcos_bootstrap.ipv4_address_private}\" >> ips.txt"
	}
	  
    provisioner "local-exec" {
      command = "echo CLUSTER_NAME=\"${var.cluster_name}\" >> ips.txt"
    }  
    
    provisioner "local-exec" {
       command = "rm -rf ./do-install.sh"
    }
    
    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_vm} && echo done waiting bootstrap VM ready"
    }

    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${self.ipv4_address}"
    }

    provisioner "file" {
      source = "./install/prepSystem.sh"
      destination = "/tmp/prepSystem.sh"
    }
 
    provisioner "remote-exec" {
	  inline = "bash /tmp/prepSystem.sh > /tmp/prepSystem.log"
	}
    
}

resource "null_resource" "dcos_bootstrap_docker" {
    
    count = "${var.install_docker}"
    depends_on = ["ibm_compute_vm_instance.dcos_bootstrap"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${ibm_compute_vm_instance.dcos_bootstrap.ipv4_address}"
    }
    
    provisioner "file" {
      source = "./install/installDocker.sh"
      destination = "/tmp/installDocker.sh"
    }

     provisioner "remote-exec" {
	  inline = "bash /tmp/installDocker.sh > /tmp/installDocker.log"
	}
     
}


resource "null_resource" "dcos_bootstrap_install" {
    
    depends_on = ["null_resource.dcos_bootstrap_docker", "ibm_compute_vm_instance.dcos_master"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${ibm_compute_vm_instance.dcos_bootstrap.ipv4_address}"
    }

    provisioner "remote-exec" {
  		inline = [
   			 "wget -q -O dcos_generate_config.sh -P $HOME ${var.dcos_installer_url}",
   			 "mkdir $HOME/genconf"
    	]
  	}
  
  	provisioner "local-exec" {
    	command = "./make-files.sh"
  	}

	provisioner "local-exec" {
    	command = "sed -i -e '/^- *$/d' ./config.yaml"
  	}
  	
	provisioner "file" {
    	source = "./ip-detect"
    	destination = "$HOME/genconf/ip-detect"
  	}
  	
	provisioner "file" {
    	source = "./config.yaml"
   		destination = "$HOME/genconf/config.yaml"
  	}
  	
    provisioner "remote-exec" {
  	  inline = ["sudo bash $HOME/dcos_generate_config.sh",
              "docker run -d -p 4040:80 -v $HOME/genconf/serve:/usr/share/nginx/html:ro nginx 2>/dev/null",
              "docker run -d -p 2181:2181 -p 2888:2888 -p 3888:3888 --name=dcos_int_zk jplock/zookeeper 2>/dev/null"
              ]
    }
           
}

resource "null_resource" "dcos_bootstrap_install_iptables" {

    count = "${var.install_iptables}"

    depends_on = ["null_resource.dcos_bootstrap_install"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${ibm_compute_vm_instance.dcos_bootstrap.ipv4_address}"
    }

    provisioner "file" {
      source = "./do-install-bootstrap-iptables.sh"
      destination = "/tmp/do-install-bootstrap-iptables.sh"
    }

	provisioner "remote-exec" {
	    inline = "bash /tmp/do-install-bootstrap-iptables.sh> /tmp/enable-iptables.log"
	}

}

resource "ibm_compute_vm_instance" "dcos_master" {

    count  = "${var.master_count}"

    hostname = "${format("${var.cluster_name}-master-%02d", count.index)}"
    domain            = "${var.ibm_sl_domain}"
    ssh_key_ids       = ["${ibm_compute_ssh_key.mykey.id}"]
    os_reference_code = "${var.ibm_sl_os_reference_code}"
    datacenter        = "${var.ibm_sl_datacenter}"
  
    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.ssh_public_key_path}")}\"\n"

    hourly_billing = "true"
    local_disk = "true"

    cores = "${var.master_cores}"
    memory = "${var.master_memory}"
    network_speed = "${var.master_network}"
    disks = "${var.master_disk}"
  
  	provisioner "local-exec" {
	    command = "echo ${format("MASTER_%02d", count.index)}=\"${self.ipv4_address_private}\" >> ips.txt"
	}

    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_vm} && echo done waiting master VM ready"
    }

    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${self.ipv4_address}"
    }

    provisioner "file" {
      source = "./install/prepSystem.sh"
      destination = "/tmp/prepSystem.sh"
    }
 
    provisioner "remote-exec" {
	  inline = "bash /tmp/prepSystem.sh > /tmp/prepSystem.log"
	}
  
}

resource "null_resource" "dcos_master_docker" {
    
    count = "${var.install_docker * var.master_count}"
    depends_on = ["ibm_compute_vm_instance.dcos_master"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(ibm_compute_vm_instance.dcos_master.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "./install/installDocker.sh"
      destination = "/tmp/installDocker.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/installDocker.sh > /tmp/installDocker.log"
	}
}

resource "null_resource" "dcos_master_install" {

    count = "${var.master_count}"
    depends_on = ["null_resource.dcos_bootstrap_install", "null_resource.dcos_master_docker"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(ibm_compute_vm_instance.dcos_master.*.ipv4_address, count.index)}"
    }

	  provisioner "file" {
	    source = "./do-install.sh"
	    destination = "/tmp/do-install.sh"
	  }

	  provisioner "remote-exec" {
	    inline = "bash /tmp/do-install.sh master  > /tmp/install-master.log"
	  }
}

resource "null_resource" "dcos_master_install_iptables" {

    count = "${var.install_iptables * var.master_count}"
    depends_on = ["null_resource.dcos_master_install"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(ibm_compute_vm_instance.dcos_master.*.ipv4_address, count.index)}"
    }

	 provisioner "file" {
        source = "./do-install-master-iptables.sh"
        destination = "/tmp/do-install-master-iptables.sh"
      }
       
      provisioner "remote-exec" {
	    inline = "bash /tmp/do-install-master-iptables.sh> /tmp/enable-iptables.log"
	  }

}

resource "ibm_compute_vm_instance" "dcos_agent" {
  
    count         = "${var.agent_count}"

    hostname = "${format("${var.cluster_name}-agent-%02d", count.index)}"
    domain            = "${var.ibm_sl_domain}"
    ssh_key_ids       = ["${ibm_compute_ssh_key.mykey.id}"]
    os_reference_code = "${var.ibm_sl_os_reference_code}"
    datacenter        = "${var.ibm_sl_datacenter}"

    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.ssh_public_key_path}")}\"\n"

    hourly_billing = "true"
    local_disk = "true"

    cores = "${var.agent_cores}"
    memory = "${var.agent_memory}"
    network_speed = "${var.agent_network}"
    disks = "${var.agent_disk}"

    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_vm} && echo done waiting agent VM ready"
    }

    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${self.ipv4_address}"
    }

    provisioner "file" {
      source = "./install/prepSystem.sh"
      destination = "/tmp/prepSystem.sh"
    }
 
    provisioner "remote-exec" {
	  inline = "bash /tmp/prepSystem.sh > /tmp/prepSystem.log"
	}
     
}
  

resource "null_resource" "dcos_agent_docker" {
    
    count = "${var.install_docker * var.agent_count}"
    depends_on = ["ibm_compute_vm_instance.dcos_agent"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(ibm_compute_vm_instance.dcos_agent.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "./install/installDocker.sh"
      destination = "/tmp/installDocker.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/installDocker.sh > /tmp/installDocker.log"
	}
}

resource "null_resource" "dcos_agent_install" {

    count = "${var.agent_count}"
    
    depends_on = ["null_resource.dcos_bootstrap_install","null_resource.dcos_agent_docker"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(ibm_compute_vm_instance.dcos_agent.*.ipv4_address, count.index)}"
    }

  	  provisioner "file" {
	    source = "do-install.sh"
	    destination = "/tmp/do-install.sh"
	  }
	  
	  provisioner "remote-exec" {
	    inline = "bash /tmp/do-install.sh slave  > /tmp/install-slave.log"
	  }
	  	  
}

resource "null_resource" "dcos_agent_install_iptables" {

    count = "${var.install_iptables * var.agent_count}"
    
    depends_on = ["null_resource.dcos_agent_install"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(ibm_compute_vm_instance.dcos_agent.*.ipv4_address, count.index)}"
    }

     provisioner "file" {
        source = "./do-install-agent-iptables.sh"
        destination = "/tmp/do-install-agent-iptables.sh"
      }
       
      provisioner "remote-exec" {
	    inline = "bash /tmp/do-install-agent-iptables.sh > /tmp/enable-iptables.log"
	  }
	  	  
}


resource "ibm_compute_vm_instance" "dcos_public_agent" {
  
    count         = "${var.public_agent_count}"

    hostname = "${format("${var.cluster_name}-public-agent-%02d", count.index)}"
    domain            = "${var.ibm_sl_domain}"
    ssh_key_ids       = ["${ibm_compute_ssh_key.mykey.id}"]
    os_reference_code = "${var.ibm_sl_os_reference_code}"
    datacenter        = "${var.ibm_sl_datacenter}"

    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.ssh_public_key_path}")}\"\n"

    hourly_billing = "true"
    local_disk = "true"

    cores = "${var.agent_cores}"
    memory = "${var.agent_memory}"
    network_speed = "${var.agent_network}"
    disks = "${var.agent_disk}"

    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_vm} && echo done waiting agent VM ready"
    }

    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${self.ipv4_address}"
    }

    provisioner "file" {
      source = "./install/prepSystem.sh"
      destination = "/tmp/prepSystem.sh"
    }
 
    provisioner "remote-exec" {
	  inline = "bash /tmp/prepSystem.sh > /tmp/prepSystem.log"
	}
     
}
  

resource "null_resource" "dcos_public_agent_docker" {
    
    count = "${var.install_docker * var.public_agent_count}"
    depends_on = ["ibm_compute_vm_instance.dcos_public_agent"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(ibm_compute_vm_instance.dcos_public_agent.*.ipv4_address, count.index)}"
    }
    
 
    provisioner "file" {
      source = "./install/installDocker.sh"
      destination = "/tmp/installDocker.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/installDocker.sh > /tmp/installDocker.log"
	}
}

resource "null_resource" "dcos_public_agent_install" {

    count = "${var.public_agent_count}"
    
    depends_on = ["null_resource.dcos_bootstrap_install","null_resource.dcos_public_agent_docker"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(ibm_compute_vm_instance.dcos_public_agent.*.ipv4_address, count.index)}"
    }

  	  provisioner "file" {
	    source = "do-install.sh"
	    destination = "/tmp/do-install.sh"
	  }
	  
	  provisioner "remote-exec" {
	    inline = "bash /tmp/do-install.sh slave_public  > /tmp/install-public-slave.log"
	  }

}

resource "null_resource" "dcos_public_agent_install_iptables" {

    count = "${var.install_iptables * var.public_agent_count}"
    
    depends_on = ["null_resource.dcos_public_agent_install"]
    connection {
      user = "${var.ibm_sl_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(ibm_compute_vm_instance.dcos_public_agent.*.ipv4_address, count.index)}"
    }

      provisioner "file" {
        source = "./do-install-agent-iptables.sh"
        destination = "/tmp/do-install-agent-iptables.sh"
      }
       
      provisioner "remote-exec" {
	    inline = "bash /tmp/do-install-agent-iptables.sh > /tmp/enable-iptables.log"
	  }	  
}
