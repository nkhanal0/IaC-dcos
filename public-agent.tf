resource "aws_instance" "public-agent" {
  ami = "${lookup(var.amis, var.aws_region)}"
  availability_zone = "${var.aws_region}a"
  instance_type = "${var.instance_type.public-agent}"
  key_name = "${var.key_pair_name}"
  vpc_security_group_ids = ["${aws_security_group.private.id}"]
  subnet_id = "${aws_subnet.availability-zone-private.id}"
  source_dest_check = false
  count = "${var.dcos_public_agent_count}"
  user_data =  "${template_file.public_agent_user_data.rendered}"

  root_block_device {
    volume_size = "${var.dcos_agent_disk_size}"
    delete_on_termination = true
  }
  tags {
    Name = "${format("${var.pre_tag}-Public-Agent-%d-${var.post_tag}", count.index + 1)}"
  }
}

resource "template_file" "public_agent_user_data" {
  template = "${file(format("%s/files/user-data/agent-cloud-config.yaml.tpl", path.module))}"

  vars {
    bootstrap_url = "http://${aws_instance.bootstrap.private_ip}:9999"
    private_subnet_cidr = "${var.private_subnet_cidr}"
    nfs_server_ip = "${aws_instance.master.0.private_ip}"
    role = "slave_public"
  }

  lifecycle {
    create_before_destroy = true
  }
}
