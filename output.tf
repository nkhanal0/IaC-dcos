output "agent_ips" {
  value = "${trimspace(null_resource.intermediates.triggers.agent_ips)}"
}

output "agent_count" {
  value = "${var.public_agent_asg_desired_capacity + var.agent_asg_desired_capacity}"
}

output "private_primary_subnet_id" {
  value = "${aws_subnet.private-primary.id}"
}

output "private_secondary_subnet_id" {
  value = "${aws_subnet.private-secondary.id}"
}

output "public_primary_subnet_id" {
  value = "${aws_subnet.public-primary.id}"
}

output "public_secondary_subnet_id" {
  value = "${aws_subnet.public-secondary.id}"
}

output "private_subnet_availability_zone" {
  value = "${aws_subnet.private-primary.availability_zone}"
}

output "public_agent_ids" {
  value = "${trimspace(null_resource.intermediates.triggers.public_agent_ids)}"
}

output "dcos_url" {
  value = "${trimspace(null_resource.intermediates.triggers.dcos_url)}"
}

output "bootstrap_ip" {
  value = "${aws_instance.bootstrap.private_ip}"
}

output "private_security_group_id" {
  value = "${aws_security_group.private.id}"
}

output "public_security_group_id" {
  value = "${aws_security_group.public.id}"
}

output "nat_gateway_public_ip" {
  value = "${aws_nat_gateway.nat.public_ip}"
}

output "elb_logstash_id" {
  value = "${aws_elb.logstash.id}"
}

output "jenkins_url" {
  value = "https://${var.jenkins_dns_record_name}.${var.domain_name}"
}

output "s3_bucket_name" {
  value = "${aws_s3_bucket.cluster-storage.bucket}"
}
