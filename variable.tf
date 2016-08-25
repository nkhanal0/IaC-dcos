variable "key_pair_name" {
}
variable "vpc_id" {
}
variable "public_subnet_id" {
}
variable "public_security_group_id" {
}
variable "pre_tag" {
}
variable "post_tag" {
}
variable "tag_service" {
  description = "Service tag"
}
variable "tag_environment" {
  description = "Environment tag"
}
variable "tag_version" {
  description = "Version tag"
}
variable "dcos_master_disk_size" {
  description = "The size of Master node root block device disk in GB"
  default = "30"
}
variable "dcos_agent_disk_size" {
  description = "The size of Agent node root block device disk in GB"
  default = "30"
}

variable "aws_region" {
  description = "EC2 Region for the VPC"
}

variable "coreos_amis" {
  description = "CoreOS AMIs by region used in master and agent nodes"
  default = {
    ap-northeast-1 = "ami-56498b37"
    ap-southeast-1 = "ami-b9ed34da"
  }
}

variable "centos_amis" {
  description = "CentOS AMIs by region user in bootstrap node"
  default = {
    ap-southeast-1 = "ami-f068a193"
    ap-northeast-1 = "ami-eec1c380"
  }
}

variable "dcos_cluster_name" {
  description = "DC/OS cluster name"
}
variable "dcos_username" {
  description = "DC/OS Username"
}
variable "dcos_password" {
  description = "DC/OS password"
}

variable "dcos_master_count" {
  description = "Master count"
  default = "3"
}

variable "private_subnet_cidr" {
  description = "CIDR for the Private Subnet"
  default = "10.0.1.0/24"
}

variable "nfs_access_address" {
  description = "NFS server access address"
  default = "10.0.1.0/16"
}

variable "dcos_installer_url" {
  description = "DCOS installer url"
  default = "https://downloads.mesosphere.com/dcos/stable/dcos_generate_config.ee.sh"
}

variable "master_user_data" {
  description = "Master Cloud config files"
  default = {
    "0" = "%s/files/user-data/nfs-master-cloud-config.yaml.tpl"
    "1" = "%s/files/user-data/master-cloud-config.yaml.tpl"
  }
}

variable "instance_type" {
  description = "DCOS instance type"
  default = {
    "bootstrap" = "m4.large"
    "master" = "m4.large"
    "public-agent" = "m4.large"
    "agent" = "m4.large"
  }
}

variable "aws_ssl_certificate_arn_id" {
  description = "ARN ID of the ssl certificate created in Amazon"
  default = ""
}


variable "agent_asg_max_size" {
  description = "The maximum size of the auto scale group (Max agent count)."
  default = "5"
}

variable "agent_asg_min_size" {
  description ="The minimum size of the auto scale group (Min agent count)."
  default = "1"
}

variable "agent_asg_desired_capacity" {
  description = "The number of Amazon EC2 instances (agents) that should be running in the group."
  default = "3"
}

variable "agent_asg_health_check_grace_period" {
  description = "After instance comes into service before checking health."
  default = "300"
}

variable "agent_asg_health_check_type" {
  description = "EC2 or ELB. Controls how health checking is done."
  default = "EC2"
}

variable "public_agent_asg_max_size" {
  description = "The maximum size of the auto scale group (Max public agent count)."
  default = "5"
}

variable "public_agent_asg_min_size" {
  description ="The minimum size of the auto scale group (Min public agent count)."
  default = "1"
}

variable "public_agent_asg_desired_capacity" {
  description = "The number of Amazon EC2 instances ( public agents) that should be running in the group."
  default = "3"
}

variable "public_agent_asg_health_check_grace_period" {
  description = "After instance comes into service before checking health."
  default = "300"
}

variable "public_agent_asg_health_check_type" {
  description = "EC2 or ELB. Controls how health checking is done."
  default = "EC2"
}
variable "hosted_zone_id" {
  description = "ID for the domain hosted zone"
}

variable "domain_name" {
  description = "Name of the domain where record(s) need to create"
}

variable "master_dns_record_name" {
  description = "Name of the record that you want to create for load balancer"
}

variable "tyk_dns_record_name" {
  description = "Name of the record that you want to create for load balancer"
}

variable "s3_bucket_name" {
  description = "AWS S3 Bucket name"
}

variable "filebeat_docker_image" {
  description = "Filebeat docker image form public docker registry"
  default= "vysakhqb/filebeat"
}
