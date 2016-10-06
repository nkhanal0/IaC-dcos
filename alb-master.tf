# Create a new load balancer
resource "aws_alb" "master" {
  name            = "${var.pre_tag}-Master-ALB-${var.post_tag}"
  internal        = false
  security_groups = ["${aws_security_group.public.id}"]
  subnets         = ["${aws_subnet.public-primary.id}","${aws_subnet.public-secondary.id}"]


  tags {
    Name = "${var.pre_tag}-Master-${var.post_tag}"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
}

resource "aws_alb_target_group" "dcos-masters" {
  name     = "${var.pre_tag}-Master"
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
