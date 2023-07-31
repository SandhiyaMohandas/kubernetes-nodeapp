# DevOps Assessment
## _intro_

hi...

this is an assessment that consist of four stages, complete each stage as you see fit, then submit it to a github repo.

## _Prerequisites_

This assessment requires running a k8s cluster (k3d), you can run the cluster on your personal machine or for a better environment you can use any cloud service (e.g, an ec2 instance from AWS).
To complete this assessment your machine need to have the following installed :

- docker
- make (CLI tool)
- WSL (in case you are running windows)


## I - environment preparation

This assessment uses a lightweight k8s cluster called k3d that can simulate a cluster of more than one node on your personal machine. 

∴ the first part of the asseessment is to install _k3d_.

## II - cluster preparation 

Once k3d is installed, you can run the command `make cluster` in the root dirctory of the project, this command will create a k3d cluster of one node. once the cluster is created you can interact with it using `kubectl`.

First, in order to prepare the cluster you will need to install _helm_ (the k8s package manager). 

Afterwards, you need to install and deploy the following services to your cluster: 

- nginx ingress 
- prometheus 

## III - service deployment

- create a dockerfile for the nodejs sample service in the root dir.
- create a deployment file for the sample service with the following conditions :
    - set a soft limit and a hard limit on the service resources consumption.
    - deploy the service without root privileges.
    - limlit the deployment capabilities to only the necessary ones.
    - set the filesystem to be read only.
    - disallow privilege escalation.
    - livenessProbe and readinessProbe must be set on the deployment file (you can find the health endpoit by browsing to /sample-service/index.js).
- create a service file for the sample service.
- create an ingress file that exposes the sample service to outside of the cluster.

all the resources mentioned above should exist on the same one namespace, and the service should be running and accessible. 

## IV - bonus

- deploy jenkins (CICD tool) to your cluster using helm.
- create a pipeline in jenkins that consists of two main stages : 
    - stage 1 : build the sample service docker image and pushes it to dockerhub.
    - stage 2 : deploy the sample service to the cluster with a rollout strategy.


 ✨ Good Luck ✨
