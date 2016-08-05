resource "template_file" "autoscaling_group_public_agent_instances_bash" {
  template = "${file("./files/bash/autoscaling_group_instances.bash.tpl")}"
  vars {
    autoscaling_group_name = "${aws_autoscaling_group.dcos_public_agent_asg.name}"
    instance_id_output_file_name = "public_agent_ids.txt"
  }
}

resource "template_file" "autoscaling_group_agent_instances_bash" {
  template = "${file("./files/bash/autoscaling_group_instances.bash.tpl")}"
  vars {
    autoscaling_group_name = "${aws_autoscaling_group.dcos_agent_asg.name}"
    instance_id_output_file_name = "private_agent_ids.txt"
  }
}

resource "null_resource" "retrieve-autoscaling-group-instances" {
  provisioner "local-exec" {
    command = "sudo easy_install awscli"
  }
  provisioner "local-exec" {
    command = "${template_file.autoscaling_group_public_agent_instances_bash.rendered}"
  }
  provisioner "local-exec" {
    command = "${template_file.autoscaling_group_agent_instances_bash.rendered}"
  }
  provisioner "local-exec" {
    command = "agent_ips=$(<agent_ips.txt) && echo agent_ips = $agent_ips >> ../terraform.out"
  }
  provisioner "local-exec" {
    command = "private_agent_ids=$(<private_agent_ids.txt) && echo private_agent_ids = $private_agent_ids >> ../terraform.out"
  }
  provisioner "local-exec" {
    command = "public_agent_ids=$(<public_agent_ids.txt) && echo public_agent_ids = $public_agent_ids >> ../terraform.out"
  }
}

output "agent_ips" {
  value = "${file("agent_ips.txt")}"
}
output "master_elb_dns_name" {
  value = "${aws_elb.master.dns_name}"
}
output "private_subnet_id" {
  value = "${aws_subnet.availability-zone-private.id}"
}
output "private_subnet_availability_zone" {
  value = "${aws_subnet.availability-zone-private.availability_zone}"
}
output "private_agent_ids" {
  value = "${file("private_agent_ids.txt")}"
}
output "public_agent_ids" {
  value = "${file("public_agent_ids.txt")}"
}
