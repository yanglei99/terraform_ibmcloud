 #!/bin/bash
 
echo reference "https://docs.mesosphere.com/1.11/installing/oss/custom/system-requirements/"
 
echo Upgrade CentOS

sudo yum upgrade --assumeyes --tolerant
sudo yum update --assumeyes

sudo systemctl stop firewalld && sudo systemctl disable firewalld
sudo systemctl disable dnsmasq && sudo systemctl stop dnsmasq

echo disable sudo password prompt

echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo Enable NTP

sudo yum install -y ntp ntpdate ntp-doc

service ntpd stop
ntpdate 0.rhel.pool.ntp.org
service ntpd start
ntptime
adjtimex -p
timedatectl

echo Advance setup

sudo yum install -y tar xz unzip curl ipset

sudo sed -i s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config
sudo groupadd nogroup
sudo groupadd docker

echo Enable OverlayFS

sudo tee /etc/modules-load.d/overlay.conf <<-'EOF'
overlay
EOF

sudo reboot
