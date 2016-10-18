# Create a new load balancer for Jenkins
resource "aws_alb" "jenkins" {
  name            = "${null_resource.alias.triggers.lb_pre_tag}-Jenkins-${null_resource.alias.triggers.lb_post_tag}"
  internal        = true
  security_groups = ["${aws_security_group.public.id}"]
  subnets         = ["${aws_subnet.private-primary.id}","${aws_subnet.private-secondary.id}"]


  tags {
    Name = "${var.pre_tag}-Jenkins-ALB"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
}

resource "aws_alb_target_group" "jenkins-agents" {
  name     = "${var.pre_tag}-Jenkins-TG"
  port     = 10000
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    port = 9090
    path = "/haproxy?stats"
  }
}

resource "aws_alb_listener" "front_end_jenkins" {
  load_balancer_arn = "${aws_alb.jenkins.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2015-05"
  certificate_arn = "${var.aws_ssl_certificate_arn_id}"

  default_action {
    target_group_arn = "${aws_alb_target_group.jenkins-agents.arn}"
    type = "forward"
  }
}
resource "aws_route53_record" "jenkins_record" {
  zone_id = "${var.hosted_zone_id}"
  name = "${var.jenkins_dns_record_name}.${var.domain_name}"
  type = "A"

  alias {
    name = "${aws_alb.jenkins.dns_name}"
    zone_id = "${aws_alb.jenkins.zone_id}"
    evaluate_target_health = false
  }
}
