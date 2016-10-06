resource "aws_subnet" "public-primary" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.public_primary_subnet_cidr}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags {
    Name = "${var.pre_tag}-Public-Primary-${var.post_tag}"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
}
resource "aws_route_table_association" "availability-zone-public-primary" {
  subnet_id = "${aws_subnet.public-primary.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "public-secondary" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.public_secondary_subnet_cidr}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags {
    Name = "${var.pre_tag}-Public-Secondary-${var.post_tag}"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
}
resource "aws_route_table_association" "availability-zone-public-secondary" {
  subnet_id = "${aws_subnet.public-secondary.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.internet_gateway_id}"
  }
  tags {
    Name = "${var.pre_tag}-Internet-Gateway-${var.post_tag}"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
}

resource "aws_security_group" "public" {
  name = "${var.pre_tag}-Public-${var.post_tag}"
  description = "DC/OS public security group"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 9090
    to_port = 9090
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 10000
    to_port = 10000
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "${var.pre_tag}-Public-${var.post_tag}"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
}

