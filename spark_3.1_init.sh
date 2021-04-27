#!/bin/sh

tar -xvf spark-3.1.1-bin-hadoop3.2.tgz
mkdir -p /usr/local/
sudo mv spark-3.1.1-bin-hadoop3.2 /usr/local/
sudo ln -s /usr/local/spark-3.1.1-bin-hadoop3.2/ /usr/local/spark

cat <<EOF > /etc/profile 
export PATH="/root/kubernetes/cluster/ubuntu/binaries/:$PATH"
export SPARK_HOME=/usr/local/spark
export PATH=${SPARK_HOME}/bin:$PATH
EOF
source /etc/profile

cd /usr/local/spark
./bin/docker-image-tool.sh -r $1:5000 -t v3.1.1 build
docker push $1:5000/spark:3.1.1
#docker push 192.168.101.130:5000/spark-r:v1
#pyspark
./bin/docker-image-tool.sh -r $1:5000 -t v3.1.1 -p ./kubernetes/dockerfiles/spark/bindings/python/Dockerfile build

#为spark程序创建serviceaccount和对应的rbac
#kubectl create namespace spark-namespace
kubectl create serviceaccount spark
kubectl create clusterrolebinding spark-role --clusterrole=edit --serviceaccount=default:spark --namespace=default
#kubectl config set-context --current --namespace=spark-namespace
kubectl config set-context --current --namespace=default
# 运行spark的example sparkPi
kubectl proxy --address=0.0.0.0  --port=8009
spark-submit \
  --master k8s://http://127.0.0.1:8009 \
  --deploy-mode cluster \
  --name spark-pi \
  --class org.apache.spark.examples.SparkPi \
  --conf spark.executor.instances=3 \
  --conf spark.kubernetes.container.image=192.168.101.130/spark:v3.1.1 \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  local:///path/to/examples.jar
  
 #! bin/sh
cat <<EOF > /etc/profile 
export PATH=/usr/local/anaconda3/bin:$PATH
export PYSPARK_PYTHON=python3  # 指定的是python3
export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS="notebook"
EOF
source /etc/profile

./bin/docker-image-tool.sh -r $1:5000 -t v3.1.1 -p ./kubernetes/dockerfiles/spark/bindings/python/Dockerfile build
docker push $1:5000/spark-py:v3.1.1

spark-submit \
    --master k8s://http://127.0.0.1:8009 \
    --deploy-mode cluster \
    --name spark-example \
    --conf spark.executor.instances=3 \
    --conf spark.kubernetes.container.image=192.168.101.130:5000/spark-py:v3.1.1 \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
    --conf spark.kubernetes.pyspark.pythonVersion=3 \
    /usr/bin/run.py

