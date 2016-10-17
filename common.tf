resource "null_resource" "alias" {
  triggers = {
    s3_bucket_name = "${replace(lower(var.pre_tag), "/[^0-9a-z-]/","")}"
  }
}