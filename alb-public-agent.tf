/* Create a new load balancer */
resource "aws_alb" "tyk" {
  name            = "${null_resource.alias.triggers.lb_pre_tag}-Tyk-${null_resource.alias.triggers.lb_post_tag}"
  internal        = false
  security_groups = ["${aws_security_group.public.id}"]
  subnets         = ["${aws_subnet.public-primary.id}","${aws_subnet.public-secondary.id}"]

  tags {
    Name = "${var.pre_tag}-Tyk-ALB"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
}

resource "aws_alb_target_group" "dcos-public-agents" {
  name     = "${var.pre_tag}-Tyk"
  port     = 10081
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    port = 9090
    path = "/haproxy?stats"
  }
}

resource "aws_alb_listener" "front_end_tyk" {
  load_balancer_arn = "${aws_alb.tyk.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2015-05"
  certificate_arn = "${var.aws_ssl_certificate_arn_id}"

  default_action {
    target_group_arn = "${aws_alb_target_group.dcos-public-agents.arn}"
    type = "forward"
  }
}

resource "aws_route53_record" "tyk_record" {
  zone_id = "${var.hosted_zone_id}"
  name = "${var.tyk_dns_record_name}.${var.domain_name}"
  type = "A"

  alias {
    name = "${aws_alb.tyk.dns_name}"
    zone_id = "${aws_alb.tyk.zone_id}"
    evaluate_target_health = false
  }
}
