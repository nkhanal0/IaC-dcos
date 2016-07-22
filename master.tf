resource "aws_instance" "master" {
  ami = "${lookup(var.amis, var.aws_region)}"
  availability_zone = "${var.aws_region}a"
  instance_type = "m4.large"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = [
    "${aws_security_group.private.id}"]
  subnet_id = "${aws_subnet.availability-zone-private.id}"
  source_dest_check = false
  count = "${var.dcos_master_count}"
  user_data = "${file("${lookup(var.master_user_data, signum(count.index))}")}"
  connection {
    user = "core"
    agent = false
    private_key = "${file(var.aws_key_path)}"
  }
  root_block_device {
    volume_size = "${var.dcos_master_disk_size}"
    delete_on_termination = true
  }
  tags {
    Name = "${format("${var.pre_tag}-Master-%d-${var.post_tag}", count.index + 1)}"
  }
  provisioner "local-exec" {
    command = "rm -rf ./do-install.sh"
  }
  provisioner "local-exec" {
    command = "echo ${format("MASTER_%02d", count.index)}=\"${self.private_ip}\" >> ips.txt"
  }
  provisioner "local-exec" {
    command = "sed -i 's@PRIVATE_SUBNET_CIDR@\"${var.private_subnet_cidr}\"@g' agent-cloud-config.yaml"
  }
  provisioner "local-exec" {
    command = "sed -i 's@NFS_SERVER_IP@${aws_instance.master.0.private_ip}@g' agent-cloud-config.yaml"
  }
}

resource "null_resource" "setup-master" {
  depends_on = ["aws_instance.bootstrap"]
  count = "${var.dcos_master_count}"
  connection {
    host = "${element(aws_instance.master.*.private_ip, count.index)}"
    user = "core"
    agent = false
    private_key = "${file(var.aws_key_path)}"
  }
  provisioner "file" {
    source = "./do-install.sh"
    destination = "/tmp/do-install.sh"
  }
  provisioner "remote-exec" {
    inline = "bash /tmp/do-install.sh master"
  }
}
