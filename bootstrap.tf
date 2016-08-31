resource "aws_instance" "bootstrap" {
  ami = "${lookup(var.centos_amis, var.aws_region)}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  instance_type = "${var.instance_type["bootstrap"]}"
  key_name = "${var.key_pair_name}"
  vpc_security_group_ids = ["${aws_security_group.private.id}"]
  subnet_id = "${aws_subnet.private-primary.id}"
  source_dest_check = false

  tags {
    Name = "${var.pre_tag}-Bootstrap-${var.post_tag}"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }

  root_block_device {
    volume_size = "10"
    delete_on_termination = true
  }

  provisioner "local-exec" {
    command = "echo BOOTSTRAP=\"${aws_instance.bootstrap.private_ip}\" >> ips.txt"
  }
  provisioner "local-exec" {
    command = "echo CLUSTER_NAME=\"${var.dcos_cluster_name}\" >> ips.txt"
  }
  provisioner "local-exec" {
    command = "echo DCOS_USERNAME=\"${var.dcos_username}\" >> ips.txt"
  }
  provisioner "local-exec" {
    command = "echo 77faa1f1-80aa-4a74-7bd1-53e90b8979c5 > UUID"
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
}


resource "null_resource" "dcos-installation" {
  depends_on = ["aws_route_table_association.availability-zone-private"]
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

  provisioner "local-exec" {
    command = "${path.module}/make-files.sh"
  }
  provisioner "local-exec" {
    command = "sed -i -e '/^- *$/d' ./config.yaml"
  }
  provisioner "file" {
    source = "./UUID"
    destination = "$HOME/UUID"
  }
  provisioner "file" {
    source = "./ip-detect"
    destination = "$HOME/genconf/ip-detect"
  }
  provisioner "file" {
    source = "./config.yaml"
    destination = "$HOME/genconf/config.yaml"
  }
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com/ | sh",
      "sudo service docker start",
      "sudo systemctl enable docker",
      "sudo bash dcos_generate_config.sh --hash-password ${var.dcos_password} > secret_hash",
      "sed -i -n '$p' secret_hash",
      "echo 'superuser_password_hash:' $(cat $HOME/secret_hash) >> $HOME/genconf/config.yaml",
      "sudo bash $HOME/dcos_generate_config.sh",
      "sudo docker run --restart=always -d -p 9999:80 -v $HOME/genconf/serve:/usr/share/nginx/html:ro nginx 2>/dev/null"
    ]
  }
}

