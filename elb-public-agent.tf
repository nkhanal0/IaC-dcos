resource "aws_elb" "tyk" {
  name = "${var.pre_tag}-Tyk-ELB"
  subnets = ["${var.public_subnet_id}"]
  security_groups = ["${var.public_security_group_id}"]

  /* Tyk gateway port */
  listener {
    instance_port = 10081
    instance_protocol = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${var.aws_ssl_certificate_arn_id}"
  }

  health_check {
    healthy_threshold = 9
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:9090/haproxy?stats"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 300

  tags {
    Name = "${var.pre_tag}-Tyk-ELB-${var.post_tag}"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
}

resource "aws_route53_record" "tyk_record" {
  zone_id = "${var.hosted_zone_id}"
  name = "${var.tyk_dns_record_name}.${var.domain_name}"
  type = "A"

  alias {
    name = "${aws_elb.tyk.dns_name}"
    zone_id = "${aws_elb.tyk.zone_id}"
    evaluate_target_health = false
  }
}
