#!/bin/bash
 
echo reference "https://docs.docker.com/engine/installation/linux/docker-ce/centos/"

echo remove previously installed docker

sudo yum remove docker docker-common docker-selinux docker-engine

sudo yum install -y yum-utils device-mapper-persistent-data lvm2

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y docker-ce

yum list docker-ce --showduplicates | sort -r

sudo systemctl start docker

sudo docker run hello-world
