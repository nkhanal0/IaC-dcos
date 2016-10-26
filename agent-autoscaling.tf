resource "aws_launch_configuration" "dcos_agent_lc" {
  name_prefix = "${var.pre_tag}-Agent-AS-LC-"
  image_id = "${lookup(var.coreos_amis, var.aws_region)}"
  instance_type = "${var.instance_type["agent"]}"
  key_name = "${var.key_pair_name}"
  security_groups = ["${aws_security_group.private.id}"]
  user_data = "${data.template_file.agent_user_data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.s3_profile_agents.name}"

  root_block_device {
    volume_size = "${var.dcos_agent_disk_size}"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "dcos_agent_asg" {
  availability_zones = [
    "${data.aws_availability_zones.available.names[0]}"
  ]
  name = "${var.pre_tag}-Agent-AS-group-${var.post_tag}"
  max_size = "${var.agent_asg_max_size}"
  min_size = "${var.agent_asg_min_size}"
  desired_capacity = "${var.agent_asg_desired_capacity}"
  health_check_type = "${var.agent_asg_health_check_type}"
  health_check_grace_period = "${var.agent_asg_health_check_grace_period}"
  launch_configuration = "${aws_launch_configuration.dcos_agent_lc.name}"
  vpc_zone_identifier = ["${aws_subnet.private-primary.id}"]

  tag {
    key = "Name"
    value = "${var.pre_tag}-Agent-${var.post_tag}"
    propagate_at_launch = true
  }
  tag {
    key = "Service"
    value = "${var.tag_service}"
    propagate_at_launch = true
  }
  tag {
    key = "Environment"
    value = "${var.tag_environment}"
    propagate_at_launch = true
  }
  tag {
    key = "Version"
    value = "${var.tag_version}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "autoscaling_group_public_agent_instances_bash" {
  template = "${file("${path.module}/files/bash/autoscaling_group_instances.bash.tpl")}"
  vars {
    public_agent_autoscaling_group_name = "${aws_autoscaling_group.dcos_public_agent_asg.name}"
    private_agent_autoscaling_group_name = "${aws_autoscaling_group.dcos_agent_asg.name}"
    instance_id_output_file_name = "public_agent_ids.txt"
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
