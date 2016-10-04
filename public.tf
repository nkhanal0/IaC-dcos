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
  route_table_id = "${var.public_route_table_id}"
}
