# About
A terraform template that will provision a webserver environment with full vpc network, security and monitoring integration on AWS. 

## Architecture
TODO

## Instructions
If you havent already done so:
1. Install [terraform](https://www.terraform.io/downloads.html).
2. `git clone` the repo.
3. Setup an AWS user account with **programmatic access** enabled. Attach policies that allow for EC2 +  VPC provisioning. Note down the **access key ID** and **secret key**. 

Otherwise:
1. Run `terraform init` in the cloned directory. 
2. Create an **env.tf** file and fill out required variables (use **env.tf.sample** as a template).
3. Run `terraform apply`. 
4. Run `terraform delete -target=aws_instance.terraform_instance` to delete the ec2 image template instance after completion.

## What this template creates
Network Layer:
1. A VPC
2. Four subnets (2 private + 2 public) across 2 availability zones
3. Internet gateway
4. Two routing tables (1 private + 1 public)

Security Layer:
1. NACLs for private and public subnets
2. Security Groups for webserver and Elastic Load Balancer

Compute Layer:
1. A webserver serving VueJS via NodeJS + Express
2. A local private key for webserver SSH
2. An AMI using the webserver as the base image
3. Launch Config + ASG + ELB (Classic) serving the AMI

