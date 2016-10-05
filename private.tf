data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_security_group" "private" {
  name = "${var.pre_tag}-Security-Private-${var.post_tag}"
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
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
}

resource "aws_subnet" "private-primary" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.private_primary_subnet_cidr}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags {
    Name = "${var.pre_tag}-Private-Primary-${var.post_tag}"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
}

resource "aws_route_table_association" "availability-zone-private-primary" {
  subnet_id = "${aws_subnet.private-primary.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_subnet" "private-secondary" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.private_secondary_subnet_cidr}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags {
    Name = "${var.pre_tag}-Private-Secondary-${var.post_tag}"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
}

resource "aws_route_table_association" "availability-zone-private-secondary" {
  subnet_id = "${aws_subnet.private-secondary.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.public-primary.id}"

  provisioner "local-exec" {
    command = "echo 'nat_gateway_public_ip=\"${self.public_ip}\"' >> ../terraform.out"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    Name = "${var.pre_tag}-Private-Subnet-${var.post_tag}"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
}


