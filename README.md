### IaC: DCOS
This terraform script with setup the DCOS cluster in AWS.
 - CentOS (Bootstrap Node)
 - CoreOS (Master and Agent Nodes)
 - Private subnet
 - Public subnet
 - Internet gateway

#### Pre-requisites
- An IAM account with administrator privileges.
- A VPC with a Public Subnet
- Install terraform in the machine: https://www.terraform.io/intro/getting-started/install.html

#### Steps to install DCOS
- Clone this repo .
- Copy your AWS ssh key into current dir.
- `cp terraform.dummy terraform.tfvars`
- Modify params in `terraform.tfvars`
- Modify params in `variable.tf` to change subnet or add AMI accordingly to your aws region
- Run `terraform plan` to see the plan to execute.
- Run `terraform apply` to run the scripts.
- You may have `prod/dev/stage` configurations in
`terraform.tfvars.{prod/dev/stage}` files (already ignored by `.gitignore`).

#### Notes
- The AWS key name, AWS key path, VPC, Subnet, Security Group will be updated to `terraform.dummy`
and AWS ssh key will be copied to the current directory if `IaC: Manager` installation is done.
