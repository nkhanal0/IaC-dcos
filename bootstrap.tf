resource "aws_instance" "bootstrap" {
  ami = "${lookup(var.centos_amis, var.aws_region)}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  instance_type = "${var.instance_type["bootstrap"]}"
  key_name = "${var.key_pair_name}"
  vpc_security_group_ids = ["${aws_security_group.private.id}"]
  subnet_id = "${aws_subnet.private-primary.id}"
  source_dest_check = false
  iam_instance_profile = "${aws_iam_instance_profile.bootstrap.name}"

  tags {
    Name = "${var.pre_tag}-Bootstrap-${var.post_tag}"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }

  root_block_device {
    volume_size = "32"
    delete_on_termination = true
  }

  provisioner "local-exec" {
    command = "echo 'private_security_group_id = \"${aws_security_group.private.id}\"' >> ../terraform.out"
  }
  provisioner "local-exec" {
    command = "echo 'private_subnet_az = \"${aws_subnet.private-primary.availability_zone}\"' >> ../terraform.out"
  }
  provisioner "local-exec" {
    command = "echo 'private_subnet_id = \"${aws_subnet.private-primary.id}\"' >> ../terraform.out"
  }
  provisioner "local-exec" {
    command = "echo 'agent_count = \"${var.public_agent_asg_desired_capacity + var.agent_asg_desired_capacity}\"' >> ../terraform.out"
  }
  provisioner "local-exec" {
    command = "echo 's3_bucket_name = \"${aws_s3_bucket.cluster-storage.bucket}\"' >> ../terraform.out"
  }
  provisioner "local-exec" {
    command = "echo 'bootstrap_ip = \"${aws_instance.bootstrap.private_ip}\"' >> ../terraform.out"
  }

  connection {
    user = "centos"
    agent = true
  }
}

data "template_file" "dcos_configuration" {
  template = "${file("${path.module}/files/config.yaml.tpl")}"
  vars {
    bootstrap_url = "${aws_instance.bootstrap.private_ip}"
    dcos_cluster_name = "${var.dcos_cluster_name}"
    master_lb_dns = "${aws_alb.master.dns_name}"
    master_count = "${var.dcos_master_count}"
    aws_region = "${var.aws_region}"
    s3_bucket = "${aws_s3_bucket.cluster-storage.bucket}"
  }
}

resource "null_resource" "download-dcos-installer" {
  depends_on = ["aws_route_table_association.availability-zone-private-primary"]
  connection {
    host = "${aws_instance.bootstrap.private_ip}"
    user = "centos"
    agent = true
  }
  provisioner "remote-exec" {
    inline = [
      "curl ${var.dcos_installer_url["${var.dcos_edition}"]} > dcos_generate_config.sh",
      "rm -r $HOME/genconf; mkdir $HOME/genconf"
    ]
  }
}

resource "null_resource" "dcos-installation" {
  // Remove first 2 dependencies
  depends_on = ["null_resource.download-dcos-installer","aws_autoscaling_group.master"]
  connection {
    host = "${aws_instance.bootstrap.private_ip}"
    user = "centos"
    agent = true
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.dcos_configuration.rendered}' > ${path.module}/config.yaml"
  }

  provisioner "file" {
    source = "${path.module}/files/ip-detect"
    destination = "$HOME/genconf/ip-detect"
  }
  provisioner "file" {
    source = "${path.module}/config.yaml"
    destination = "$HOME/genconf/config.yaml"
  }
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com/ | sh",
      "sudo service docker start",
      "sudo systemctl enable docker",
      "sudo bash $HOME/dcos_generate_config.sh",
      "sudo docker run --restart=always -d -p 9999:80 -v $HOME/genconf/serve:/usr/share/nginx/html:ro nginx 2>/dev/null"
    ]
  }
}
