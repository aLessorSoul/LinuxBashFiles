#为spark serviceaccount and role binding
kubectl create namespace spark
kubectl create serviceaccount spark -n spark
kubectl create clusterrolebinding spark-role --clusterrole=edit --serviceaccount=default:spark --namespace=spark

# create pv and pvc
docker create -f my-notebook-pv.yaml
docker create -f my-notebook-pvc.yaml

# pull image and create deployment
docker create -f pyspark.yaml

kubectl port-forward -n spark deployment.apps/my-notebook-deployment 8888:8888 --address 0.0.0.0 