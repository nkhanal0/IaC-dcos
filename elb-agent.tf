resource "aws_elb" "agent" {
  name = "${var.pre_tag}-elb-agent-${var.post_tag}"

  subnets = ["${var.public_subnet_id}"]
  security_groups = ["${var.public_security_group_id}"]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTP:9090/haproxy?stats"
    interval = 30
  }

  listener {
    instance_port = 22
    instance_protocol = "tcp"
    lb_port = 2222
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 3000
    instance_protocol = "http"
    lb_port = 3000
    lb_protocol = "http"
  }

  listener {
    instance_port = 9090
    instance_protocol = "tcp"
    lb_port = 9090
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 8181
    instance_protocol = "http"
    lb_port = 8181
    lb_protocol = "http"
  }

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  listener {
    instance_port = 443
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 8080
    lb_protocol = "http"
  }

  instances = ["${aws_instance.public-agent.*.id}"]
  connection_draining = true
  connection_draining_timeout = 300
  tags {
    Name = "${var.pre_tag}-Agent-${var.post_tag}"
  }
}
