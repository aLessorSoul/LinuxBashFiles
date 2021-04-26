#!/bin/sh

echo installing yum utils
yum install -y yum-utils
echo installing docker
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache
systemctl start docker & systemctl enable docker