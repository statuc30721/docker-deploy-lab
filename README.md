# Build a containerized image on Docker and push to Amazon Web Service (AWS) Elastic Container Repository (ECR)

[PURPOSE] Provide basic instructions to create a container image and upload to a public or private AWS ECR.

[PREREQUISITES]

You will need to have the following prior to using these steps:
- A running EKS kubernetes cluster
- AWS console credentials
- AWS CLI access
- Kubernetes Cluster access
- Docker installed on a local system. You can use Docker on MacOS, Linux or Windows. Docker desktop will be used in these procedures. 
- AWS ClI installed and configured with credentials
- kubectl installed and configured to access your AWS EKS cluster
- Dockerfile for building the Docker image
- A deployment.yaml manifest for deploying the application
- A graphical (e.g. VS Code) or command line (e.g. VI, VIM, Nano) text editor to create and edit the required files.

## Create Project Folder
1. Create a working directory with your project name. In this example it is docker-deploy-lab

mkdir docker-deploy-lab

2. Move into the project lab

cd docker-deploy-lab

## Create the Dockerfile
1. Create a Dockerfile using a text editor. The file should be named Dockerfile.

    vim Dockerfile

2. Add the content below to the Dockerfile. I included comments for clarity. Please modify/remove the comments as you see fit.

```
    # Create a container image from nginx:stable
    FROM nginx:stable

    # Update and upgrade the exisiting installed packages, and 
    # install any additional required packages.
    RUN apt-get update && \
        apt-get upgrade -y
        
    # Expose port 80 on the deployed container to allow access.
    # When deployed in a kubernetes cluster your security group (if setup) will need 
    # to allow traffic to port 80.
    EXPOSE 80

    # CMD instruction to start Nginx when the container starts
    CMD ["nginx", "-g", "daemon off;"]
  
```

  ![Dockerfile](/graphics/vim-dockerfile.png)

3. Save the file and exit the editor if using a command line application (e.g. VI). If using a graphical editor it is not neccessary.

## Build the Docker Image

1. Run the command below to build a docker image. We will "tag" the image with the name demo_nginx_image

 docker build -t demo_nginx_image .

 [NOTE] The "dot" at the end of the file is neccessary if running this from the command line as that is telling docker to put the image in the current directory.

 ![Docker build](/graphics/docker-build.png)

 ## Configure AWS CLI

 [REFERENCE(s)]
 https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

 https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html


 1. Install AWS CLI (if not already present on your system). 

 - Linux 
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

- MacOS
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg AWSCLIV2.pkg -target /

- Windows
    Download the AWS CLI MSI installed for Windows and install
    https://awscli.amazonaws.com/AWSCLIV2.msi


2. Verify AWS CLI version 
aws --version


3. Configure AWS CLI with your credentials
    aws configure
    
    You will be prompted to enter the following information:
    - AWS Access Key ID
    - AWS Secret Access Key
    - Identify the default AWS region
    - Set the desired output format (e.g. JSON)

4. Verify the AWS CLI is properly configured
    aws configure list

    You should see the information you input in the previous step. The access_key and secret_key fields are intentionally partially obscured.

## Install Terraform


[REFERENCE(s)]

https://developer.hashicorp.com/terraform/install


Terraform community edition runs on MacOS, Windows and Linux operating systems. Reference the procedures for the operating system you will be deploying the container image.

## Create Terraform configuration code

For demonstration purposes we have identifed the name of a file to hold our terraform code named ecr_demo_nginx.tf. 

For your project you can provide your own file name. Be sure to have the file name end in .tf

1. Create a file named ecr_demo_nginx.tf in your editor of choice.

2. Insert the content below, inlcuding the comment section beginning with #: 
```
    terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 6.11.0"
        }
    }
    }

    provider "aws" {
    region = "us-east-1"
    }

    # Identify name of Docker Image in ECR. Here we use the tag name of the image.

    resource "aws_ecr_repository" "demo_nginx_image" {
    name = "demo_nginx_image"
    }
```
  [NOTE] The AWS terraform version changes often, so the version presented here may be newer or older than what you will encounter in other repositories.

    ![Terraform configuration](/graphics/vim-terraform-config.png)

3. Intialize Terraform and deploy the configuration.

    - terraform init
    - terraform validate
    - terraform plan # Review the output and make sure it matches what you require.
    - terraform apply # You will need to answer yes after running this command

    This should create a folder with the lead name of your image in the Amazon ECR Registry. Depending on how you have your ECR setup the file may go into the Public or Private repository.


## Push Docker image to AWS ECR

1. Login to the AWS Management Console and access the Elasic Container Registry

2. Select the "Repositories" link.

3. Verify your image repository is listed.

4. Select your repository and then select "View push commands".

5. Follow the provided commands

![Docker push to ECR](/graphics/docker-push-to-ecr.png)

6. Once you have finished pushing the file to ECR, refresh your browser so you can verify that your image was uploaded to the repository.

![Image uploaded to ECR](/graphics/aws-ecr-image-uploaded.png)

## AWS Elastic Kubernetes Cluster Access

We now have an image in AWS ECR repository. You will need to either have a running EKS cluster or deploy an EKS cluster.

You will need to have kubectl installed on your system that is deploying the container image to EKS.

1. Install kubectl

[REFERENCE] 
https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html

The kubectl application can be installed on Linux, MacOS and Windows operating systems.

Follow the procedure in the provided reference.

2. Configure your user account to be able to connect to your EKS cluster.

aws eks update-kubeconfig --region <region where your cluster is running> --name <name of cluster>

Example: 

aws eks update-kubeconfig --region us-east-1 --name demo

Verify connection to your kubernetes cluster

kubectl config view


kubectl create namespace -n 
3. Create a deployment YAML file and input the contents below in the file and save as demo_nginx_deployment.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: //ecr-image
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: 100m
              memory: 256Mi
            limits:
              cpu: 100m
              memory: 256Mi
```

[CAUTION] You must input the actual URI of the image that is in the ECR repository.

For example: 

<You input your account number in this field>.dkr.ecr.us-east-1.amazonaws.com/demo_nginx_image:latest

XXXXXXXXX912.dkr.ecr.us-east-1.amazonaws.com/demo_nginx_image:latest

4. Deploy the mainfest file using kubectl.

kubectl apply -f demo_nginx_deployment.yaml

5. Verify the deployment and pod status

kubectl get deployments

kubectl get pods

5. Provide console access to the application

Enable port-forwarding in the pod running the application

kubectl port-forward //name of the pod// 8080:80

You obtain the name of the pod from the kubectl command "kubectl get pods"

If you see the the "Welcome to nginx!" message than your pod is running and your deployment was successful.

![Application Accessible](/graphics/demo-nginx-deployment-worked.png)


  