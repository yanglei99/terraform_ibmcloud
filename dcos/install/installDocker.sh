#!/bin/bash
 
echo reference "https://dcos.io/docs/1.9/administration/installing/custom/system-requirements/"

echo verify OS level and overlay

uname -r
lsmod | grep overlay

echo config docker yum repo

sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF


echo config systemd to run docker with overlay

sudo mkdir -p /etc/systemd/system/docker.service.d && sudo tee /etc/systemd/system/docker.service.d/override.conf <<- EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --storage-driver=overlay
EOF

echo install docker

sudo yum install -y docker-engine-1.13.1 docker-engine-selinux-1.13.1
sudo systemctl start docker
sudo systemctl enable docker

sudo docker ps

