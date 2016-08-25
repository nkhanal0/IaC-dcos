output "agent_ips" {
  value = "${trimspace(null_resource.intermediates.triggers.agent_ips)}"
}
output "agent_count" {
  value = "${var.public_agent_asg_desired_capacity + var.agent_asg_desired_capacity}"
}
output "private_subnet_id" {
  value = "${aws_subnet.availability-zone-private.id}"
}
output "private_subnet_availability_zone" {
  value = "${aws_subnet.availability-zone-private.availability_zone}"
}
output "public_agent_ids" {
  value = "${trimspace(null_resource.intermediates.triggers.public_agent_ids)}"
}
output "dcos_url" {
  value = "http://${aws_elb.master.dns_name}"
}
output "dcos_acs_token" {
  value = "${trimspace(null_resource.intermediates.triggers.dcos_acs_token)}"
}
output "bootstrap_ip" {
  value = "${aws_instance.bootstrap.private_ip}"
}
output "private_security_group_id" {
  value = "${aws_security_group.private.id}"
}
output "nat_gateway_public_ip" {
  value = "${aws_nat_gateway.nat.public_ip}"
}
output "elb_logstash_id" {
  value = "${aws_elb.logstash.id}"
}

data "template_file" "autoscaling_group_public_agent_instances_bash" {
  template = "${file("${path.module}/files/bash/autoscaling_group_instances.bash.tpl")}"
  vars {
    public_agent_autoscaling_group_name = "${aws_autoscaling_group.dcos_public_agent_asg.name}"
    private_agent_autoscaling_group_name = "${aws_autoscaling_group.dcos_agent_asg.name}"
    instance_id_output_file_name = "public_agent_ids.txt"
  }
}

resource "null_resource" "intermediates" {
  depends_on = ["null_resource.retrieve-autoscaling-group-instances", "null_resource.dcos-cli-installation"]
  triggers = {
    agent_ips = "${file("${path.root}/agent_ips.txt")}"
    public_agent_ids = "${file("${path.root}/public_agent_ids.txt")}"
    dcos_acs_token = "${file("${path.root}/dcos_acs_token.txt")}"
  }
}

resource "null_resource" "retrieve-autoscaling-group-instances" {
  provisioner "local-exec" {
    command = "sudo easy_install awscli"
  }
  provisioner "local-exec" {
    command = "${data.template_file.autoscaling_group_public_agent_instances_bash.rendered}"
  }

}

data "template_file" "dcos-cli-installation-script" {
  template = "${file("${path.module}/files/bash/install_dcos_cli.tpl")}"
  vars {
    master_elb_dns_name = "${aws_elb.master.dns_name}"
    dcos_username = "${var.dcos_username}"
    dcos_password = "${var.dcos_password}"
  }
}

resource "null_resource" "dcos-cli-installation" {
  depends_on = ["null_resource.dcos-installation"]
  provisioner "local-exec" {
    command = "${data.template_file.dcos-cli-installation-script.rendered}"
  }
}
