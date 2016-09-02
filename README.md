### IaC: DCOS
This terraform script will setup the DCOS cluster in AWS.
 - Bootstrap Node (CentOS)
 - Master and Agent Nodes (CoreOS)
 - Private subnet
 - Public subnet
 - Internet gateway

#### Pre-requisites
- An IAM account with administrator privileges.
- (skip if you use [IaC-manager][iac-manager]) An existing infrastructure with a VPC, Subnet and instance from where this terraform can be run.
  We need the following information prior to starting the script.
  - public_security_group_id
  - public_subnet_id
  - vpc_id
  - key_pair_name 
  We have an [Iac-manager][iac-manager] which can do this task.
- Install terraform in the machine from [here][terraform-install]. Terraform v0.7.0 or above is required.
- Public Key Access with Agent support/ Agent Forwarding:

  ```bash
  ssh-add <key_pair_name>.pem
  ssh -A centos@<manager_public_ip>
  ```
- A hosted zone in AWS Route53 for your domain name. This is required to create a record for creating a friendly dns name for the load balancer.
  - If you do not want to create a dns name for load balancer, remove the `aws_route53_record` resource from `elb-master.tf`

#### Steps to install DCOS
- Export AWS credentials as bash variables
```
export AWS_ACCESS_KEY_ID="anaccesskey" 
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_DEFAULT_REGION="ap-northeast-1"
```
- Clone this repo.
- Copy your AWS ssh key into current dir.
- `cp terraform.dummy terraform.tfvars`
- If you are using [IaC-Manager][iac-manager], run ```cat ~/terraform.out >> ~/IaC-dcos/terraform.tfvars``` once.
- Modify params in `terraform.tfvars`
- (Optional) Modify params in `variable.tf` to change **default values** including subnet or add AMI accordingly to your aws region
- Run `terraform plan` to see the plan to execute.
- Run `terraform apply` to run the scripts.
- You may have `prod/dev/stage` configurations in
`terraform.tfvars.{prod/dev/stage}` files (already ignored by `.gitignore`).

#### Notes
- The AWS key name, AWS key path, VPC, Subnet, Security Group will be updated to `terraform.dummy` if the installation is done by [IaC-Manager][iac-manager].


[iac-manager]: <https://github.com/microservices-today/IaC-manager>
[terraform-install]: <https://www.terraform.io/intro/getting-started/install.html>
