# Go to local folder
mkdir project-4

# Build container
docker build -t user-service ./backend/user-service

# Run container
docker run -d -p 8000:8000 --name user-service user-service

### Test in Browser or Postman
👉 http://localhost:8000/

### To stop the running container
docker stop user-service

### To start it again
docker start user-service

### To remove it completely
docker rm -f user-service

### Folder Structure
project-4/
│── backend/
│   ├── user-service/
│   │   ├── main.py
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   ├── product-service/ (optional)
│── frontend/
│   ├── src/
│   ├── public/
│   ├── Dockerfile
│   ├── package.json
│── api-gateway/
│   ├── kong.yml
│── docker-compose.yml


## Installation
### Install jenkins in Kubernetes with Helm
kubectl create namespace jenkins
kubectl get namespace
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm install jenkins oci://ghcr.io/jenkinsci/helm-charts/jenkins -n jenkins
kubectl get service -n jenkins 
kubectl edit service jenkins -n jenkins  ### (Line 44, change type: ClusterIP to type: LoadBalancer)

##### If the External IP Doesn't Work (Local Clusters):
kubectl port-forward service/jenkins 8080:8080 -n jenkins
kubectl get service -n jenkins

##### Retrieve the Jenkins administrator password
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password

##### Access:
http://127.0.0.1:8080/

##### Login
Username: admin
Password: bvbZpLBwhVm4kGvlvYKMtM

### Uninstall jenkins in Kubernetes with Helm
helm uninstall jenkins -n jenkins
kubectl delete namespace jenkins
kubectl get pv 
kubectl delete pv <pv-name> 
helm repo remove jenkins
helm repo update

kubectl get pods -n jenkins  
kubectl get svc -n jenkins   
kubectl get deployments -n jenkins  
kubectl get pv 
helm list -n jenkins