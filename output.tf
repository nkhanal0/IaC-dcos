output "agent_ips" {
  value = "${null_resource.intermediates.triggers.agent_ips}"
}
output "private_subnet_id" {
  value = "${aws_subnet.availability-zone-private.id}"
}
output "private_subnet_availability_zone" {
  value = "${aws_subnet.availability-zone-private.availability_zone}"
}
output "public_agent_ids" {
  value = "${null_resource.intermediates.triggers.public_agent_ids}"
}
output "dcos_url" {
  value = "https://${aws_elb.master.dns_name}"
}
output "dcos_acs_token" {
  value = "${null_resource.intermediates.triggers.dcos_acs_token}"
}
output "bootstrap_ip" {
  value = "${aws_instance.bootstrap.private_ip}"
}

data "template_file" "autoscaling_group_public_agent_instances_bash" {
  template = "${file("./files/bash/autoscaling_group_instances.bash.tpl")}"
  vars {
    public_agent_autoscaling_group_name = "${aws_autoscaling_group.dcos_public_agent_asg.name}"
    private_agent_autoscaling_group_name = "${aws_autoscaling_group.dcos_agent_asg.name}"
    instance_id_output_file_name = "public_agent_ids.txt"
  }
}

resource "null_resource" "intermediates" {
  depends_on = ["null_resource.retrieve-autoscaling-group-instances", "null_resource.dcos-cli-installation"]
  triggers = {
    agent_ips = "${file("agent_ips.txt")}"
    public_agent_ids = "${file("public_agent_ids.txt")}"
    dcos_acs_token = "${file("dcos_acs_token.txt")}"
  }
}

resource "null_resource" "retrieve-autoscaling-group-instances" {
  provisioner "local-exec" {
    command = "sudo easy_install awscli"
  }
  provisioner "local-exec" {
    command = "${data.template_file.autoscaling_group_public_agent_instances_bash.rendered}"
  }
  provisioner "local-exec" {
    command = "agent_ips=$(<agent_ips.txt) && echo agent_ips = $agent_ips >> ../terraform.out"
  }
  provisioner "local-exec" {
    command = "public_agent_ids=$(<public_agent_ids.txt) && echo public_agent_ids = $public_agent_ids >> ../terraform.out"
  }
  provisioner "local-exec" {
    command = "echo bootstrap_ip = \"${aws_instance.bootstrap.private_ip}\" >> ../terraform.out"
  }
}

data "template_file" "dcos-cli-installation-script" {
  template = "${file("./files/bash/install_dcos_cli.tpl")}"
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
