#!/bin/sh

tar -xvf spark-2.4.7-bin-hadoop2.7.tgz
mkdir -p /usr/local/
sudo mv spark-2.4.7-bin-hadoop2.7 /usr/local/
sudo ln -s /usr/local/spark-2.4.7-bin-hadoop2.7/ /usr/local/spark

cat <<EOF > /etc/profile 
export PATH="/root/kubernetes/cluster/ubuntu/binaries/:$PATH"
export SPARK_HOME=/usr/local/spark
export PATH=${SPARK_HOME}/bin:$PATH
EOF
source /etc/profile

cd /usr/local/spark
./bin/docker-image-tool.sh -r $1 -t v2.4.7 build
docker push $1:5000/spark:v1
#docker push 192.168.101.130:5000/spark-r:v1

#为spark程序创建serviceaccount和对应的rbac
kubectl create serviceaccount spark
#kubectl delete serviceaccount spark
kubectl create namespace spark
#kubectl delete clusterrolebinding spark-role 
kubectl create clusterrolebinding spark-role --clusterrole=edit --serviceaccount=default:spark --namespace=spark

# 运行spark的example sparkPi
kubectl proxy --address=0.0.0.0  --port=8009
spark-submit \
  --master k8s://http://127.0.0.1:8009 \
  --deploy-mode cluster \
  --name spark-pi \
  --class org.apache.spark.examples.SparkPi \
  --conf spark.executor.instances=3 \
  --conf spark.kubernetes.container.image=192.168.101.130:5000/spark:v2.4.7 \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  /opt/spark/examples/jars/spark-examples_2.11-2.4.7.jar
  

