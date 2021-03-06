# IaC: DCOS
This terraform script will setup the DCOS cluster in AWS.
 - Bootstrap Node (CentOS)
 - Master and Agent Nodes (CoreOS)
 - Private subnet
 - Public subnet
 - Internet gateway

#### Pre-requisites
- With IaC-Manager or skip to manual steps
  - Use [IaC-manager](https://github.com/microservices-today/IaC-manager) to create a manager node. Then SSH into the manager node and perform the steps for installation. 
- Manual steps
  - An IAM account with privileges mentioned [here](https://github.com/microservices-today/IaC-manager#iac-manager-node-jump-server).
  - An existing infrastructure with a VPC, Subnet and instance from where this terraform can be run.
    We need the following information prior to starting the script.
    - vpc_id
    - key_pair_name 
    We have an [Iac-manager][iac-manager] which can do this task.
  - Install terraform in the machine from [here][terraform-install]. Terraform v0.7.0 or above is required.
- Public Key Access with Agent support/ Agent Forwarding:

  ```bash
  ssh-add <key_pair_name>.pem
  ssh -A centos@<manager_public_ip>
  ```
- Hosted zone in AWS Route53 for your domain name. This is required to create a record for creating a friendly dns name for the load balancer.
  - If you do not want to create a dns name for load balancer, remove the `aws_route53_record` resource from `elb-master.tf`
- "Accept Software Terms" of aws marketplace for [CentOS](https://aws.amazon.com/marketplace/search/results?searchTerms=centos&page=1&ref_=nav_search_box) or [CoreOS](https://aws.amazon.com/marketplace/search/results?searchTerms=coreos&page=1&ref_=nav_search_box).


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
- If unable to perform `terraform destroy`, instance profile can be removed using aws cli only.
  `aws iam list-instance-profiles | grep InstanceProfileName`
  `aws iam delete-instance-profile --instance-profile-name ${var.pre_tag}_s3_profile_master_${var.post_tag}`
  `aws iam delete-instance-profile --instance-profile-name ${var.pre_tag}_s3_profile_agents_${var.post_tag}`
  `aws iam delete-instance-profile --instance-profile-name ${var.pre_tag}_s3_profile_public_agent_${var.post_tag}`

[iac-manager]: <https://github.com/microservices-today/IaC-manager>
[terraform-install]: <https://www.terraform.io/intro/getting-started/install.html>

#### Contributing
1. Make a feature branch: __git checkout -b your-username/your-feature__
2. Follow Terraform Style Guide
3. Make your feature. Keep things tidy so you have one commit per self-contained change (squashing can help).
4. Push your branch: __git push -u origin your-username/your-feature__
5. Open GitHub to the repo,
   under "Your recently pushed branches", click __Pull Request__ for
   _your-username/your-feature_.

Be sure to use a separate feature branch and pull request for every
self-contained feature.  If you need to make changes from feedback, make
the changes in place rather than layering on commits (use interactive
rebase to edit your earlier commits).  Then use __git push --force
origin your-feature__ to update your pull request.
