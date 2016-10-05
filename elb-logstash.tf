resource "aws_elb" "logstash" {
  name = "${var.pre_tag}-Logstash-ELB-${var.post_tag}"
  subnets = ["${aws_subnet.public-primary.id}"]
  security_groups = ["${aws_security_group.public.id}"]

  "listener" {
    instance_port = 5044
    instance_protocol = "tcp"
    lb_port            = 80
    lb_protocol        = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "TCP:22"
    interval = 30
  }

  provisioner "local-exec" {
    command = "echo 'elb_logstash_id=\"${self.id}\"' >> ../terraform.out"
  }
}