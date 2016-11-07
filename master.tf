/* Cloud-Config */
data "template_file" "master_user_data" {
  count = "${var.dcos_master_count}"
  template = "${file("${format(lookup(var.master_user_data, signum(count.index)), path.module)}")}"

  vars {
    bootstrap_url = "http://${aws_instance.bootstrap.private_ip}:9999"
    private_subnet_cidr = "${var.private_primary_subnet_cidr}"
    nfs_access_address = "${var.nfs_access_address}"
    role = "master"
    logstash_uri = "${aws_elb.logstash.dns_name}:80"
    filebeat_image = "${var.filebeat_docker_image}"
    dcos_timezone = "${var.dcos_timezone}"
    sysdig_access_key = "${var.sysdig_access_key}"
    dcos_name = "${var.pre_tag}-${var.post_tag}"
  }
}

/* ASG */
resource "aws_launch_configuration" "master" {
  name_prefix = "${var.pre_tag}-Master"
  image_id = "${lookup(var.coreos_amis, var.aws_region)}"
  instance_type = "${var.instance_type["master"]}"
  key_name = "${var.key_pair_name}"
  security_groups = ["${aws_security_group.private.id}"]
  user_data = "${data.template_file.master_user_data.1.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.s3_profile_master.name}"
  root_block_device {
    volume_size = "${var.dcos_master_disk_size}"
    delete_on_termination = true
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "master" {
  name = "${var.pre_tag}-Master-${var.post_tag}"
  max_size = "${var.master_asg_max_size}"
  min_size = "${var.master_asg_min_size}"
  desired_capacity = "${var.dcos_master_count}"
  health_check_type = "${var.master_asg_health_check_type}"
  health_check_grace_period = "${var.master_asg_health_check_grace_period}"
  launch_configuration = "${aws_launch_configuration.master.name}"
  vpc_zone_identifier = ["${aws_subnet.private-primary.id},${aws_subnet.private-secondary.id}"]
  target_group_arns = [
    "${aws_alb_target_group.master_https.arn}",
    "${aws_alb_target_group.master_http_80.arn}",
    "${aws_alb_target_group.master_http_8080.arn}",
    "${aws_alb_target_group.master_http_5050.arn}"
  ]

  tag {
    key = "Name"
    value = "${var.pre_tag}-Master-${var.post_tag}"
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

/* ALB */
resource "aws_alb" "master" {
  name            = "${null_resource.alias.triggers.lb_pre_tag}-Master-${null_resource.alias.triggers.lb_post_tag}"
  internal        = true
  security_groups = ["${aws_security_group.private.id}"]
  subnets         = ["${aws_subnet.private-primary.id}","${aws_subnet.private-secondary.id}"]

  tags {
    Name = "${var.pre_tag}-Master-${var.post_tag}"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
}

/* HTTPS */
resource "aws_alb_target_group" "master_https" {
  name     = "${var.pre_tag}-Master-Https"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    port = 5050
    path = "/health"
  }
}
resource "aws_alb_listener" "master_https" {
  load_balancer_arn = "${aws_alb.master.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2015-05"
  certificate_arn = "${var.aws_ssl_certificate_arn_id}"

  default_action {
    target_group_arn = "${aws_alb_target_group.master_https.arn}"
    type = "forward"
  }
}

/* HTTP 80 */
resource "aws_alb_target_group" "master_http_80" {
  name     = "${var.pre_tag}-Master-80"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    port = 5050
    path = "/health"
  }
}
resource "aws_alb_listener" "master_http_80" {
  load_balancer_arn = "${aws_alb.master.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.master_http_80.arn}"
    type = "forward"
  }
}

/* HTTP 8080 */
resource "aws_alb_target_group" "master_http_8080" {
  name     = "${var.pre_tag}-Master-8080"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    port = 5050
    path = "/health"
  }
}
resource "aws_alb_listener" "master_http_8080" {
  load_balancer_arn = "${aws_alb.master.arn}"
  port = "8080"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.master_http_8080.arn}"
    type = "forward"
  }
}

/* HTTP 5050 */
resource "aws_alb_target_group" "master_http_5050" {
  name     = "${var.pre_tag}-Master-5050"
  port     = 5050
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    port = 5050
    path = "/health"
  }
}
resource "aws_alb_listener" "master_http_5050" {
  load_balancer_arn = "${aws_alb.master.arn}"
  port = "5050"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.master_http_5050.arn}"
    type = "forward"
  }
}

/* Route 53 */
resource "aws_route53_record" "master_record" {
  zone_id = "${var.hosted_zone_id}"
  name = "${var.master_dns_record_name}.${var.domain_name}"
  type = "A"

  alias {
    name = "${lower(aws_alb.master.dns_name)}"
    zone_id = "${aws_alb.master.zone_id}"
    evaluate_target_health = false
  }
}
