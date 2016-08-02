resource "aws_security_group" "private" {
  name = "${var.pre_tag}-Mesos-Security-Private-${var.post_tag}"
  description = "Allow incoming connections."
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${var.vpc_id}"
  tags {
      Name = "${var.pre_tag}-Private-SG-${var.post_tag}"
  }
}

resource "aws_subnet" "availability-zone-private" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "${var.aws_region}a"
  tags {
    Name = "${var.pre_tag}-Private-Subnet-${var.post_tag}"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${var.public_subnet_id}"
}

resource "aws_route_table" "availability-zone-private" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    Name = "${var.pre_tag}-Private-Subnet-${var.post_tag}"
  }
}

resource "aws_route_table_association" "availability-zone-private" {
  subnet_id = "${aws_subnet.availability-zone-private.id}"
  route_table_id = "${aws_route_table.availability-zone-private.id}"
}