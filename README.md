# About
A terraform template set up to provision a webserver environment with full vpc network, security and monitoring integration on AWS. 

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