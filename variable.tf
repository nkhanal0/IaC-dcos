variable "aws_access_key" {
}
variable "aws_secret_key" {
}
variable "key_pair_name" {
}
variable "dcos_installer_url" {
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
variable "dcos_master_disk_size" {
}
variable "dcos_agent_disk_size" {
}

variable "registry_storage_s3_region" {
  description = "Registry storage S3 region"
}

variable "aws_region" {
  description = "EC2 Region for the VPC"
}

variable "amis" {
  description = "CoreOS AMIs by region"
  default = {
    ap-northeast-1 = "ami-962c39f8"
    ap-southeast-1 = "ami-7dc6151e"
  }
}

variable "centos_amis" {
  description = "CentOS AMIs by region"
  default = {
    ap-southeast-1 = "ami-f068a193"
    ap-northeast-1 = "ami-eec1c380"
  }
}

variable "dcos_cluster_name" {
  description = "DC/OS cluster name"
}

variable "dcos_master_count" {
  description = "Master count"
  default = "1"
}

variable "dcos_agent_count" {
  description = "Agent count"
  default = "1"
}

variable "dcos_public_agent_count" {
  description = "Public Agent count"
  default = "1"
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default = "10.0.0.0/16"
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
    "public-agent" = "m3.2xlarge"
    "agent" = "m4.large"
  }
}

variable "aws_ssl_certificate_arn_id" {
  description = "ARN ID of the ssl certificate created in Amazon"
  default = ""
}

