
tar -xvf spark-2.4.7-bin-hadoop2.7.tgz
mkdir -p /usr/local/
sudo mv spark-2.4.7-bin-hadoop2.7 /usr/local/
sudo ln -s /usr/local/spark-2.4.7-bin-hadoop2.7/ /usr/local/spark
cd /usr/local/spark
cat <<EOF > /etc/profile 
export PATH="/root/kubernetes/cluster/ubuntu/binaries/:$PATH"
export SPARK_HOME=/usr/local/spark
EOF
source /etc/profile