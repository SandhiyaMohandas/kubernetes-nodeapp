
For the ease of use & cost effectiveness, have created the cluster on my local Mac system.

High Level Steps:
Install docker.
Install k3d on your local system.
Create cluster with k3d.
Install helm.
Install kubectl
Install Nginx & Prometheus via helm.

Create kube config files for the sample-service node app
Create namespace for node-app
Create deployment.yaml, service.yaml (ClusterIP service), used the previously installed Nginx as Ingress controller
Access & verify the sample-service with /info & /health



 
