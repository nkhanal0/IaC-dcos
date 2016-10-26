resource "null_resource" "intermediates" {
  depends_on = ["null_resource.retrieve-autoscaling-group-instances", "null_resource.dcos-cli-installation"]
  triggers = {
    agent_ips = "${file("${path.root}/agent_ips.txt")}"
    public_agent_ids = "${file("${path.root}/public_agent_ids.txt")}"
    dcos_url = "http://${aws_alb.master.dns_name}"
  }
}

data "template_file" "dcos-cli-installation-script" {
  template = "${file("${path.module}/files/bash/install_dcos_cli.tpl")}"
  vars {
    master_alb_dns_name = "${aws_alb.master.dns_name}"
    dcos_username = "${var.dcos_username}"
    dcos_password = "${var.dcos_password}"
    dcos_cli_download_url = "${var.dcos_cli_download_url}"
  }
}

resource "null_resource" "dcos-cli-installation" {
  depends_on = ["null_resource.dcos-installation"]
  provisioner "local-exec" {
    command = "${data.template_file.dcos-cli-installation-script.rendered}"
  }
}

resource "null_resource" "alias" {
  triggers = {
    s3_bucket_name = "${replace(lower(var.pre_tag), "/[^0-9a-z-]/","")}-${replace(lower(var.post_tag), "/[^0-9a-z-]/","")}"
    lb_pre_tag = "${replace(replace(var.pre_tag, "/[^0-9a-zA-Z-]/",""), "/^(.{14}).*/","$1")}"
    lb_post_tag = "${replace(replace(var.post_tag, "/[^0-9a-zA-Z-]/",""), "/^(.{6}).*/","$1")}"
  }
}
