## [v1.0.5](https://github.com/microservices-today/IaC-dcos/tree/v1.0.5) (2016-08-31)
[Full Changelog](https://github.com/microservices-today/IaC-dcos/compare/v1.0.4...v1.0.5)

**FEATURES:**

- Make configurable DCOS 1.8 version [\#72](https://github.com/microservices-today/IaC-dcos/pull/72) 
- Adding filebeat and elb for logstash [\#66](https://github.com/microservices-today/IaC-dcos/pull/66) 
- Replace docker login with ECR plugin from universe [\#64](https://github.com/microservices-today/IaC-dcos/issues/64)

**ENHANCEMENTS:**

- Automated setting of availability zones [\#71](https://github.com/microservices-today/IaC-dcos/pull/71) 
- Need to configure private subnet availability zone  [\#39](https://github.com/microservices-today/IaC-dcos/issues/39)
- Replace ELB with ALB [\#67](https://github.com/microservices-today/IaC-dcos/pull/67) 
- Updating filebeat docker image [\#70](https://github.com/microservices-today/IaC-dcos/pull/70) 
- Adding policy for ECR access [\#68](https://github.com/microservices-today/IaC-dcos/pull/68) 

**BUG FIXES:**

- Update terraform from v0.7.1 to v0.7.2 [\#69](https://github.com/microservices-today/IaC-dcos/issues/69)
- Replace ELB with ALB \(Terraform 0.7.1 already supports ALB\) [\#63](https://github.com/microservices-today/IaC-dcos/issues/63)
- Update terraform from v0.7.0 to v0.7.1 [\#62](https://github.com/microservices-today/IaC-dcos/issues/62)
- Replace ELB with ALB [\#53](https://github.com/microservices-today/IaC-dcos/issues/53)

## [v1.0.4](https://github.com/microservices-today/IaC-dcos/tree/v1.0.4) (2016-08-19)
[Full Changelog](https://github.com/microservices-today/IaC-dcos/compare/v1.0.3...v1.0.4)

**FEATURES:**

- syntax corrections [\#61](https://github.com/microservices-today/IaC-dcos/pull/61) 
- Modified to support modules [\#58](https://github.com/microservices-today/IaC-dcos/pull/58) 

## [v1.0.3](https://github.com/microservices-today/IaC-dcos/tree/v1.0.3) (2016-08-19)
[Full Changelog](https://github.com/microservices-today/IaC-dcos/compare/v1.0.2...v1.0.3)

**ENHANCEMENTS:**

- Update CoreOS version to 1068.9.0 [\#59](https://github.com/microservices-today/IaC-dcos/issues/59)
- Move dcos installation script to s3 or even behind cdn [\#37](https://github.com/microservices-today/IaC-dcos/issues/37)
- pre\_tag & post\_tag should get from IaC-manager or force to enter manually [\#35](https://github.com/microservices-today/IaC-dcos/issues/35)
- Output agent\_ips for IaC of docker registry [\#32](https://github.com/microservices-today/IaC-dcos/issues/32)
- Change Route53 cname records for Master ELB [\#24](https://github.com/microservices-today/IaC-dcos/issues/24)

**Fixed bugs:**

- systemd-resolved should be disabled in CoreOS [\#36](https://github.com/microservices-today/IaC-dcos/issues/36)

**BUG FIXES:**

- Resource tagging [\#50](https://github.com/microservices-today/IaC-dcos/issues/50)
- ips.txt and config.yaml should use new files for each terraform apply [\#47](https://github.com/microservices-today/IaC-dcos/issues/47)
- User roles not getting deleted while destroying [\#44](https://github.com/microservices-today/IaC-dcos/issues/44)
- Issue with accessing IPv6 website only [\#43](https://github.com/microservices-today/IaC-dcos/issues/43)
- Remove unused TF variables [\#38](https://github.com/microservices-today/IaC-dcos/issues/38)
- Installation failed with Terraform version 0.7.0 [\#29](https://github.com/microservices-today/IaC-dcos/issues/29)
- The internal URLs are not accessible from those containers. For example : leader.mesos. [\#26](https://github.com/microservices-today/IaC-dcos/issues/26)
- Dcos root user creation should be dynamic. [\#10](https://github.com/microservices-today/IaC-dcos/issues/10)

**FEATURES:**

- Attach Tyk ELB to Public agent ASG [\#57](https://github.com/microservices-today/IaC-dcos/pull/57) 
- distribute certificates to new agents in ASG [\#56](https://github.com/microservices-today/IaC-dcos/pull/56) 
- restrict access to bucket [\#55](https://github.com/microservices-today/IaC-dcos/pull/55) 
- Added service,environment,version tags for AWS resources [\#52](https://github.com/microservices-today/IaC-dcos/pull/52) 
- Updating terraform to 0.7.0 [\#51](https://github.com/microservices-today/IaC-dcos/pull/51) 
- Added agent ips, public agent ids, dcos token to TF output [\#49](https://github.com/microservices-today/IaC-dcos/pull/49) 
- Export Terraform variables required for docker registry and api-gateway [\#46](https://github.com/microservices-today/IaC-dcos/pull/46) 
- added pre and post tag to role [\#45](https://github.com/microservices-today/IaC-dcos/pull/45) 
- Added Route53 record in hosted zone [\#42](https://github.com/microservices-today/IaC-dcos/pull/42) 

## [v1.0.2](https://github.com/microservices-today/IaC-dcos/tree/v1.0.2) (2016-08-08)
[Full Changelog](https://github.com/microservices-today/IaC-dcos/compare/v1.0.1...v1.0.2)

**FEATURES:**

- Stopping systemmd-resolve [\#41](https://github.com/microservices-today/IaC-dcos/pull/41) 
- Added IAM role to access S3 [\#40](https://github.com/microservices-today/IaC-dcos/pull/40) 

## [v1.0.1](https://github.com/microservices-today/IaC-dcos/tree/v1.0.1) (2016-08-04)
[Full Changelog](https://github.com/microservices-today/IaC-dcos/compare/v1.0.0...v1.0.1)

**BUG FIXES:**

- Remove hardcoded dcos download URL. [\#27](https://github.com/microservices-today/IaC-dcos/issues/27)
- Subnets without tags \(Name and Value\) [\#21](https://github.com/microservices-today/IaC-dcos/issues/21)
- Need to upgrade CoreOS to "CoreOS Linux \(Stable\)" \(1068.6.0\) [\#8](https://github.com/microservices-today/IaC-dcos/issues/8)
- `instance\_type` should be configurable  [\#7](https://github.com/microservices-today/IaC-dcos/issues/7)
- Why so many ports are open in Master ELB? [\#5](https://github.com/microservices-today/IaC-dcos/issues/5)
- elb-master should be with aws SSL certificate [\#4](https://github.com/microservices-today/IaC-dcos/issues/4)

**FEATURES:**

- Added output variables for IaC-api-gateway [\#34](https://github.com/microservices-today/IaC-dcos/pull/34) 
- Code cleanup  [\#31](https://github.com/microservices-today/IaC-dcos/pull/31) 

## [v1.0.0](https://github.com/microservices-today/IaC-dcos/tree/v1.0.0) (2016-08-03)
**BUG FIXES:**

- aws\_key\_path is missing in terraform.dummy [\#17](https://github.com/microservices-today/IaC-dcos/issues/17)
- `aws\_access\_key` is missing in `terraform.dummy` file [\#16](https://github.com/microservices-today/IaC-dcos/issues/16)
- Need to remove the public ELB that connects to all application. [\#9](https://github.com/microservices-today/IaC-dcos/issues/9)
- Security Groups naming is not consistent \(upper case, lower case\) [\#6](https://github.com/microservices-today/IaC-dcos/issues/6)

**FEATURES:**

- Attaching autoscaling group to public agents [\#25](https://github.com/microservices-today/IaC-dcos/pull/25) 
- Attaching autoscaling group to agent [\#22](https://github.com/microservices-today/IaC-dcos/pull/22) 
- Use SSH forwarding for TF remote execution [\#19](https://github.com/microservices-today/IaC-dcos/pull/19) 
- Provisioning to CoreOS using Cloud-Config to remove dependencies. [\#18](https://github.com/microservices-today/IaC-dcos/pull/18) 
- Amalqb/securing master elb [\#14](https://github.com/microservices-today/IaC-dcos/pull/14) 
- Revert "Removing unwanted ports in DCOS for security" [\#13](https://github.com/microservices-today/IaC-dcos/pull/13) 
- Removing unwanted ports in DCOS for security [\#12](https://github.com/microservices-today/IaC-dcos/pull/12) 
- Removing the public elb for agents [\#11](https://github.com/microservices-today/IaC-dcos/pull/11) 
- Removing private docker registry from DCOS IaC [\#3](https://github.com/microservices-today/IaC-dcos/pull/3) 
- Terraform code to setup DC/OS cluster [\#1](https://github.com/microservices-today/IaC-dcos/pull/1) 
