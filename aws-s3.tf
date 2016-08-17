resource "aws_s3_bucket" "cluster-storage" {
  bucket = "${var.s3_bucket_name}"
  tags {
    Name = "${var.pre_tag}-dcos-storage-${var.post_tag}"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
}