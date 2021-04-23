#!/bin/sh
echo building k8s on $1
echo installing java from jdk-11_linux-x64_bin.tar.gz
mkdir -p /usr/lib/jvm
tar -zxvf jdk-11_linux-x64_bin.tar.gz -C /usr/lib/jvm
cat <<EOF >  /etc/profile
export JAVA_HOME=/usr/lib/jvm/jdk-11_linux
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH
EOF
source /etc/profile

echo installing yum utils
yum install -y yum-utils
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache

echo fix static IP
oldstr="dhcp"
newstr="static"
cat /etc/sysconfig/network-scripts/ifcfg-ens33 | sed -n "s/$oldstr/$newstr/g;p"
cat /etc/sysconfig/network-scripts/ifcfg-ens33 | sed -n 's/ONBOOT="no"/ONBOOT="yes"/g;p'
cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-ens33
IPADDR=$1
NETMASK=255.255.255.0
GATEWAY=192.168.101.2
EOF
service network restart

echo turning off firewall
systemctl set-default multi-user.target
systemctl stop firewalld & systemctl disable firewalld
swapoff -a

echo installing docker
yum install docker-ce -y

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

cat <<EOF > /etc/yum.repos.d/kubernetes.repo

[kubernetes]

name=Kubernetes

baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
	http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF


cat <<EOF > /etc/sysctl.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p


echo swap off
oldstr="/dev/mapper/centos-swap"
newstr="#/dev/mapper/centos-swap"
cat /etc/fstab | sed -n "s/$oldstr/$newstr/g;p"

echo install kubelet kubeadm kubectl kubernetes-cni
yum install -y kubelet-1.20.6-0.x86_64 kubeadm-1.20.6-0.x86_64  kubectl-1.20.6-0.x86_64 
systemctl enable kubelet && systemctl start kubelet
systemctl start docker & systemctl enable docker
docker pull quay.io/coreos/flannel:v0.11.0-amd64

echo reboot
reboot