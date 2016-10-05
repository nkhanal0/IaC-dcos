resource "aws_launch_configuration" "dcos_public_agent_lc" {
  name_prefix = "${var.pre_tag}-Public-Agent-AS-LC-"
  image_id = "${lookup(var.coreos_amis, var.aws_region)}"
  instance_type = "${var.instance_type["public-agent"]}"
  key_name = "${var.key_pair_name}"
  security_groups = ["${aws_security_group.private.id}"]
  user_data = "${data.template_file.public_agent_user_data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.s3_profile_public_agent.name}"

  root_block_device {
    volume_size = "${var.dcos_agent_disk_size}"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "dcos_public_agent_asg" {
  name = "${var.pre_tag}-Public-Agent-AS-group-${var.post_tag}"

  max_size = "${var.public_agent_asg_max_size}"
  min_size = "${var.public_agent_asg_min_size}"
  desired_capacity = "${var.public_agent_asg_desired_capacity}"

  health_check_type = "${var.public_agent_asg_health_check_type}"
  health_check_grace_period = "${var.public_agent_asg_health_check_grace_period}"

  launch_configuration = "${aws_launch_configuration.dcos_public_agent_lc.name}"
  availability_zones = [
    "${data.aws_availability_zones.available.names[0]}"
  ]

  vpc_zone_identifier = ["${aws_subnet.private-primary.id}"]

  target_group_arns = ["${aws_alb_target_group.dcos-public-agents.arn}","${aws_alb_target_group.jenkins-agents.arn}"]

  force_delete = true

  tag {
    key = "Name"
    value = "${var.pre_tag}-Public-Agent-${var.post_tag}"
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
