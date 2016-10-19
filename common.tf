resource "null_resource" "alias" {
  triggers = {
    s3_bucket_name = "${replace(lower(var.pre_tag), "/[^0-9a-z-]/","")}-${replace(lower(var.post_tag), "/[^0-9a-z-]/","")}"
    lb_pre_tag = "${replace(replace(var.pre_tag, "/[^0-9a-zA-Z-]/",""), "/^(.{14}).*/","$1")}"
    lb_post_tag = "${replace(replace(var.post_tag, "/[^0-9a-zA-Z-]/",""), "/^(.{6}).*/","$1")}"
  }
}