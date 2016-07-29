resource "aws_elb" "master" {
  name = "${var.pre_tag}-elb-master-${var.post_tag}"

  subnets = ["${var.public_subnet_id}"]
  security_groups = ["${var.public_security_group_id}"]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTP:5050/health"
    interval = 30
  }

  listener {
    instance_port = 443
    instance_protocol = "https"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${var.aws_ssl_certificate_arn_id}"
  }

  instances = ["${aws_instance.master.*.id}"]
  connection_draining = true
  connection_draining_timeout = 300
  tags {
    Name = "${var.pre_tag}-Master-${var.post_tag}"
  }
}
