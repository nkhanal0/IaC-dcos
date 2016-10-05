# Create a new load balancer
resource "aws_alb" "master-internal" {
  name            = "${var.pre_tag}-Internal-${var.post_tag}"
  internal        = true
  security_groups = ["${aws_security_group.public.id}"]
  subnets         = ["${aws_subnet.private-primary.id}","${aws_subnet.private-secondary.id}"]


  tags {
    Name = "${var.pre_tag}-Internal-${var.post_tag}"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
}

resource "aws_alb_target_group" "dcos-internal" {
  name     = "${var.pre_tag}-Internal-TG"
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

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.master-internal.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2015-05"
  certificate_arn = "${var.aws_ssl_certificate_arn_id}"

  default_action {
    target_group_arn = "${aws_alb_target_group.dcos-masters.arn}"
    type = "forward"
  }
}


resource "aws_alb_listener" "front_end_http" {
  load_balancer_arn = "${aws_alb.master-internal.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.dcos-masters.arn}"
    type = "forward"
  }
}

resource "aws_route53_record" "master_record" {
  zone_id = "${var.hosted_zone_id}"
  name = "${var.master_dns_record_name}.${var.domain_name}"
  type = "A"

  alias {
    name = "${aws_alb.master-internal.dns_name}"
    zone_id = "${aws_alb.master-internal.zone_id}"
    evaluate_target_health = false
  }
}
