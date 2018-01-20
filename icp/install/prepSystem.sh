 #!/bin/bash
 
echo reference "https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/installing/prep_cluster.html"
 
echo Upgrade CentOS

sudo yum upgrade --assumeyes --tolerant
sudo yum update --assumeyes
uname -r

sudo systemctl stop firewalld && sudo systemctl disable firewalld

echo Enable NTP

sudo yum install -y ntp ntpdate ntp-doc

service ntpd stop
ntpdate 0.rhel.pool.ntp.org
service ntpd start
ntptime

echo disable SELinux

sudo sed -i s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config

echo install SSH client

yum install -y net-tools wget openssl ed

echo setup hostname for all nodes

sudo hostnamectl set-hostname $(hostname -s)

echo "root:$1" | chpasswd

echo enable sshpass

yum install -y sshpass

echo 2.6 to 2.9.x are supported 
python --version

if [ "$2" = "true" ]; then

echo Config Master Node

echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf
echo 'net.ipv4.ip_local_port_range="10240 60999"' | tee -a /etc/sysctl.conf

fi

sudo reboot