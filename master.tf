resource "aws_instance" "master" {
  ami = "${lookup(var.coreos_amis, var.aws_region)}"
  availability_zone = "${var.aws_region}a"
  instance_type = "${var.instance_type["master"]}"
  key_name = "${var.key_pair_name}"
  vpc_security_group_ids = [
    "${aws_security_group.private.id}"]
  subnet_id = "${aws_subnet.availability-zone-private.id}"
  source_dest_check = false
  count = "${var.dcos_master_count}"
  user_data = "${element(template_file.master_user_data.*.rendered, count.index)}"
  iam_instance_profile = "${aws_iam_instance_profile.s3_profile_master.name}"

  connection {
    user = "core"
    agent = true
  }

  root_block_device {
    volume_size = "${var.dcos_master_disk_size}"
    delete_on_termination = true
  }

  tags {
    Name = "${format("${var.pre_tag}-Master-%d-${var.post_tag}", count.index + 1)}"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
  provisioner "local-exec" {
    command = "echo ${format("MASTER_%02d", count.index)}=\"${self.private_ip}\" >> ips.txt"
  }
}

resource "template_file" "master_user_data" {
  count = "${var.dcos_master_count}"
  template = "${file("${format(lookup(var.master_user_data, signum(count.index)), path.module)}")}"

  vars {
    bootstrap_url = "http://${aws_instance.bootstrap.private_ip}:9999"
    private_subnet_cidr = "${var.private_subnet_cidr}"
    nfs_access_address = "${var.nfs_access_address}"
    role = "master"
    logstash_uri = "${aws_elb.logstash.dns_name}:80"
    filebeat_image = "${var.filebeat_docker_image}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
