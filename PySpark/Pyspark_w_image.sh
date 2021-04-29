#docker push 192.168.101.130:5000/spark-r:v1
kubectl create namespace spark
#为spark程序创建serviceaccount和对应的rbac
kubectl create serviceaccount spark -n spark
#kubectl delete serviceaccount spark

#kubectl delete clusterrolebinding spark-role 
kubectl create clusterrolebinding spark-role --clusterrole=edit --serviceaccount=default:spark --namespace=spark

docker create -f hostPath.yaml