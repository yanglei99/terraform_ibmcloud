#!/usr/bin/env bash

# Make some config files

mv hosts.txt etc.hosts
mv masters.txt icp.masters
mv workers.txt icp.workers
mv proxys.txt icp.proxys
mv managements.txt icp.managements
mv proxys_public.txt icp.proxys_public
mv masters_public.txt icp.masters_public

cat >> etc.hosts << FIN

127.0.0.1 localhost
FIN

# Make some scripts

cat > do-deploy.sh <<FIN
#!/bin/bash

echo https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/installing/ssh_keys.html

sudo docker pull ibmcom/icp-inception:$1

mkdir /opt/ibm-cloud-private-ce-$1
cd /opt/ibm-cloud-private-ce-$1

sudo docker run -e LICENSE=accept -v "\$(pwd)":/data ibmcom/icp-inception:$1 cp -r cluster /data

yes | ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub | sudo tee -a ~/.ssh/authorized_keys

sudo cp ~/.ssh/id_rsa ./cluster/ssh_key

for line in \$(cat /tmp/icp.masters)
do
	echo setup ssh for \$line
    sshpass -p \$1 ssh-copy-id -o StrictHostKeyChecking=no root@\$line
    ssh-keyscan \$line >> ~/.ssh/known_hosts
    ssh -t root@\$line "sudo systemctl restart sshd"
    if [ "$2" != "\$line" ]; then
	    scp /etc/hosts root@\$line:/etc/hosts
	fi
done

for line in \$(cat /tmp/icp.workers)
do
	echo setup ssh for \$line
    sshpass -p \$1 ssh-copy-id -o StrictHostKeyChecking=no root@\$line
    ssh-keyscan \$line >> ~/.ssh/known_hosts
    ssh -t root@\$line "sudo systemctl restart sshd"
    scp /etc/hosts root@\$line:/etc/hosts
done


echo [master] > ./cluster/hosts

for line in \$(cat /tmp/icp.masters)
do
	echo \$line ansible_ssh_pass=\$1 >> ./cluster/hosts
done

echo [worker] >> ./cluster/hosts

for line in \$(cat /tmp/icp.workers)
do
	echo \$line ansible_ssh_pass=\$1 >> ./cluster/hosts
done

echo [proxy] >>./cluster/hosts

for line in \$(cat /tmp/icp.proxys)
do
	echo \$line ansible_ssh_pass=\$1 >> ./cluster/hosts
done

echo [management] >> ./cluster/hosts

for line in \$(cat /tmp/icp.managements)
do
	echo \$line ansible_ssh_pass=\$1 >> ./cluster/hosts
done

echo \${PWD}/cluster/hosts content
cat ./cluster/hosts

proxy_access_ip=""
while read line; do
    if [ "\$proxy_access_ip" == "" ]; then
        proxy_access_ip="\$line"
    else
       proxy_access_ip="\$proxy_access_ip,\$line" 
    fi
done < /tmp/icp.proxys_public

master_access_ip=""
while read line; do
    if [ "\$master_access_ip" == "" ]; then
        master_access_ip="\$line"
    else
       master_access_ip="\$master_access_ip,\$line" 
    fi
done < /tmp/icp.masters_public

cat /tmp/common-config.yaml >> ./cluster/config.yaml

echo cluster_access_ip: \$master_access_ip  >> ./cluster/config.yaml
echo proxy_access_ip: \$proxy_access_ip  >> ./cluster/config.yaml
echo ansible_ssh_pass: \$1 >> ./cluster/config.yaml
echo default_admin_password: \$2 >> ./cluster/config.yaml
      
echo \${PWD}/cluster/config.yaml content
cat ./cluster/config.yaml

cd cluster

sudo docker run -e LICENSE=accept --net=host -t -v "\$(pwd)":/installer/cluster ibmcom/icp-inception:$1 install

FIN

cat > do-install-master-management-iptables.sh << FIN
#!/usr/bin/env bash

echo "enable iptables"

yum install -y iptables-services
service iptables restart
service iptables status
chkconfig --level 345 iptables on

iptables -nvL

iptables -F
# accept everything on loopback
iptables -A INPUT -i lo -j ACCEPT
# accept everything on private interface
iptables -A INPUT -i eth0 -j ACCEPT
# accept anything thats releated to connections already established
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# accept some cluster needed ports
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 53 --src 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 53 --src 10.0.0.0/8 -j ACCEPT
## kube_apiserver_port
iptables -A INPUT -p tcp -m tcp --dport 8001 -j ACCEPT
## Docker registry on master
iptables -A INPUT -p tcp -m tcp --dport 8500 -j ACCEPT
## ELK on master and management
iptables -A INPUT -p tcp -m tcp --dport 8743 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 5044 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 5046 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 9200 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 9300 -j ACCEPT
## Ingress on master and proxy
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8181 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 18080 -j ACCEPT
## Management Console on master
iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8443 -j ACCEPT
## Metering on management and master 
iptables -A INPUT -p tcp -m tcp --dport 3130 -j ACCEPT
## Liberty on master
iptables -A INPUT -p tcp -m tcp --dport 9443 -j ACCEPT
# drop every other inbound packet
iptables -P INPUT DROP

service iptables save
iptables -nvL
FIN

if [ "$3" != "true" ]; then
	echo service iptables stop >> do-install-master-management-iptables.sh
fi


cat > do-install-worker-iptables.sh << FIN
#!/usr/bin/env bash

echo "enable iptables"

yum install -y iptables-services
service iptables restart
service iptables status
chkconfig --level 345 iptables on

iptables -nvL

iptables -F
# accept everything on loopback
iptables -A INPUT -i lo -j ACCEPT
# accept everything on private interface
iptables -A INPUT -i eth0 -j ACCEPT
# accept anything thats releated to connections already established
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# accept some cluster needed ports
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 53 --src 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 53 --src 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 30000:32767 -j ACCEPT
# drop every other inbound packet
iptables -P INPUT DROP

service iptables save
iptables -nvL
FIN

if [ "$3" != "true" ]; then
	echo service iptables stop >> do-install-worker-iptables.sh
fi