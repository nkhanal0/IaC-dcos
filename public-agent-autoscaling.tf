resource "aws_launch_configuration" "dcos_public_agent_lc" {
  name_prefix = "${var.pre_tag}-Public-Agent-AS-LC-"
  image_id = "${lookup(var.coreos_amis, var.aws_region)}"
  instance_type = "${var.instance_type.public-agent}"
  key_name = "${var.key_pair_name}"
  security_groups = ["${aws_security_group.private.id}"]
  user_data = "${template_file.public_agent_user_data.rendered}"

  root_block_device {
    volume_size = "${var.dcos_agent_disk_size}"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "dcos_public_agent_asg" {
  availability_zones = ["${var.aws_region}a"]
  name = "${var.pre_tag}-Public-Agent-AS-group-${var.post_tag}"
  max_size = "${var.public_agent_asg_max_size}"
  min_size = "${var.public_agent_asg_min_size}"
  desired_capacity = "${var.public_agent_asg_desired_capacity}"
  health_check_type = "${var.public_agent_asg_health_check_type}"
  health_check_grace_period = "${var.public_agent_asg_health_check_grace_period}"
  launch_configuration = "${aws_launch_configuration.dcos_public_agent_lc.name}"
  vpc_zone_identifier = ["${aws_subnet.availability-zone-private.id}"]

  tag {
    key = "Name"
    value = "${var.pre_tag}-Public-Agent-${var.post_tag}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}