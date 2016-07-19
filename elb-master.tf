resource "aws_elb" "master" {
  name = "${var.pre_tag}-elb-master-${var.post_tag}"
//  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

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
    instance_port = 22
    instance_protocol = "tcp"
    lb_port = 2222
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 5050
    instance_protocol = "http"
    lb_port = 5050
    lb_protocol = "http"
  }

  listener {
    instance_port = 2181
    instance_protocol = "tcp"
    lb_port = 2181
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

  instances = ["${aws_instance.master.*.id}"]
//  cross_zone_load_balancing = true
//  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 300
  tags {
    Name = "${var.pre_tag}-Master-${var.post_tag}"
  }
}
