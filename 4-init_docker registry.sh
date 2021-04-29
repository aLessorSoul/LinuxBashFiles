#!/bin/sh
docker pull registry
docker create -it registry /bin/bash
docker run -d -p 5000:5000 -v /tmp/registry registry
docker ps -a
# dockerd --debug
cat <<EOF > /etc/docker/daemon.json 
{
  "insecure-registries": ["192.168.101.130:5000"],
  "registry-mirrors": ["https://5m9y9qbl.mirror.aliyuncs.com"]
}
EOF
cat <<EOF >  /etc/default/docker
DOCKER_OPT=--dns 8.8.8.8 --dns 8.8.4.4 --insecure-registry 127.0.0.1:5000
EOF
#重启docker 和所有containers
systemctl restart docker
docker start $(docker ps -a | awk '{ print $1}' | tail -n +2)

docker push $1:5000/spark:v1
#docker push $1:5000/spark-r:v1
#直接scp
#docker save $1:5000/spark:v1 > tmp.tar
#scp tmp.tar root@slave1: ~/software

docker tag master:5000/spark:spark_v1 $1:5000/spark:v1
docker push $1:5000/spark:v1
