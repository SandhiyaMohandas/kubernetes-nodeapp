
For the ease of use & cost effectiveness, have created the cluster on my local Mac system.

High Level Steps:

* Install docker.
* Install k3d on your local system.
* Create cluster with k3d.
* Install helm.
* Install kubectl
* Install Nginx & Prometheus via helm.

* Create kube config files for the sample-service node app
* Create namespace for node-app
* Create deployment.yaml, service.yaml (ClusterIP service), used the previously installed Nginx as Ingress controller
* Access & verify the sample-service with /info & /health


DETAILED STEPS:
**Install k3d on Mac:**
> curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

```
k3d version                                         
k3d version v5.5.1
k3s version v1.26.4-k3s1 (default)
```
##### Had updated the Makefile as it had some errors then in the parent folder where Makefile is present run the below command
```
# Create the files to be mounted in the container before creating the cluster
touch /var/run/docker
touch /var/log/journal
touch /etc/test
make cluster
```

The create cluster that was modified was below:
```
k3d cluster create testcluster \ 
      -p 8080:80@loadbalancer \
      -v /etc/test:/etc/test:ro  \
      -v /var/log/journal:/var/log/journal:ro \
      -v /var/run/docker.sock:/var/run/docker.sock   \
      --agents 1  \
      --k3s-arg --disable=traefik@server:0
```

This should create the k3d cluster with the mentioned configuration in the Makefile
Common commands used for troubleshooting
```
##Confirm if docker is intalled & running:
docker ps
sudo systemctl enable docker.service
sudo systemctl start docker.service
kubectl config get-contexts
k3d cluster list
k3d node list
```

**Install helm & prometheus services via helm**
```
brew install helm
helm --version

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts (add prometheus repo from helm)
kubectl create namespace prometheus (create a separate namespace for monitoring-prometheus)
helm install prometheus prometheus-community/prometheus --namespace prometheus (install prometheus with helm)
kubectl get pods -n prometheus
kubectl  get ns (to check if the prometheus namespace is created
kubectl port-forward -n prometheus deploy/prometheus-server 9090:9090 (port forward & make prometheues listen on port 9090 on the localhost)
```

**Nginx service via helm:**
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx
```

**Common kubectl & k3d troubelshooting commands used:**
```
kubectl config current-context
kubectl config get-contexts
kubectl get nodes
kubectl cluster-info
k3d cluster list
k3d node list
k3d node logs k3d-testcluster-server-0
```

**Kubernetes Sample-service deployment:**
Inside the sample-service folder, Build the Dockerfile & tag the image: **docker build . -t init1**
Troubleshoot & Test the image by locally creating a container & accessing the /info & /health

For the docker image to be available in the cluster nodes, we need to push the image to any repository to access it across the k3d cluster nodes.
As a solution, have created a public dockerhub repo (made it public to be accessible from across servers, else we can create private repo if its within the network)
Tag the image with the repo name to be pushed
```
docker login (login with the dockerhub credentials)
docker tag init1 test123456787654/test-repo:init1
docker push test123456787654/test-repo:init1
```
Create the corresponding yaml files for the sample-node service application.
Navigate to the kube-files folder & execute the following individually for the kubernetes resources to be created.
```
deploy all kube files by: 
kubectl apply -f .

or apply them individually:
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

This creates a deployment file, which pulls the docker image from the public repo: test123456787654/test-repo:init1
Created a clusterIP type service (which is default) to expose the service with the nginx ingress controller previously installed in the cluster via helm.
Since used the local for the setup, created a DNS entry in the /etc/hosts file for the local resolution to the domain, pointing to the IP address of the ingress.

To check for the application is running:
```
Exec to the pod which was created by the deployment file in the namespace (node-app) & then perform
curl http://localhost:80/info
OUTPUT:
[{"id":"1","country":"london","city":"england"},{"id":"2","country":"mars","city":"unknown"},{"id":"3","country":"here","city":"there"},{"id":"4","country":"time","city":"space"}]

curl http://localhost:80/health
OUTPUT:
[{"status":"we is good"}]

This defines that the node process is running, you can find this by **ps -aux** within the container
```

To verify if the application is accessible from outside the container but within the cluster, create a dummy container & try curl to the node-service clusterIP service.
```
kubectl get svc -n node-app
NAME               TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
node-app-service   ClusterIP   10.43.89.147   <none>        80/TCP    3h47m

kubectl run -it --rm --restart=Never curl --image=curlimages/curl:latest -- sh

curl http://10.43.89.147/info 
[{"id":"1","country":"london","city":"england"},{"id":"2","country":"mars","city":"unknown"},{"id":"3","country":"here","city":"there"},{"id":"4","country":"time","city":"space"}]

curl http://10.43.89.147/health
[{"status":"we is good"}]
```

To access the node application from the nginx as ingress, forward the traffic to a dummy domain name.
To test the domain name, add the nginx ingress IP to the /etc/hosts file along with the domain name & access it
```
kubectl get ingress -n node-app
NAME            CLASS   HOSTS                  ADDRESS                 PORTS   AGE
nginx-nodeapp   nginx   nodeapp.alraedah.com   172.23.0.2,172.23.0.3   80      3h57m

vi /etc/hosts
172.23.0.2 nodeapp.alraedah.com
172.23.0.3 nodeapp.alraedah.com
```

Then access the domain name with /info & /health
```
curl http://nodeapp.alraedah.com/health
[{"status":"we is good"}]

curl http://nodeapp.alraedah.com/info
[{"id":"1","country":"london","city":"england"},{"id":"2","country":"mars","city":"unknown"},{"id":"3","country":"here","city":"there"},{"id":"4","country":"time","city":"space"}]
```

