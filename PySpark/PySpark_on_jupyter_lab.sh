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

#其他
#修改image，提高通信模组
mkdir spark-py-tmp && cd spark-py-tmp
cp /usr/local/spark-3.1.1-bin-hadoop3.2/jars/kubernetes*jar .
cat << EOF > Dockerfile
FROM spark-py:latest
COPY *.jar /usr/local/spark/jars/
RUN rm /usr/local/spark/jars/kubernetes-*-4.12.0.jar
EOF
docker build --rm -t spark-py:v2.4.7up .

#修改image，安装jupyter
wget https://github.com/pisymbol/docker/blob/master/spark/Dockerfile
docker build --rm  -r $1:5000 -t spark-py:v2.4.7up .