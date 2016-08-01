resource "aws_instance" "public-agent" {
  depends_on = ["aws_instance.master"]
  ami = "${lookup(var.amis, var.aws_region)}"
  availability_zone = "${var.aws_region}a"
  instance_type = "${var.instance_type.public-agent}"
  key_name = "${var.key_pair_name}"
  vpc_security_group_ids = [
    "${aws_security_group.private.id}"]
  subnet_id = "${aws_subnet.availability-zone-private.id}"
  source_dest_check = false
  count = "${var.dcos_public_agent_count}"
  user_data = "${file("agent-cloud-config.yaml")}"
  connection {
    user = "core"
    agent = true
  }
  root_block_device {
    volume_size = "${var.dcos_agent_disk_size}"
    delete_on_termination = true
  }
  tags {
    Name = "${format("${var.pre_tag}-Public-Agent-%d-${var.post_tag}", count.index + 1)}"
  }
  provisioner "local-exec" {
    command = "echo ${format("AGENT_%02d", count.index + var.dcos_agent_count)}=\"${self.private_ip}\" >> ips.txt"
  }
}

resource "null_resource" "setup-public-agent" {
  count = "${var.dcos_public_agent_count}"
  depends_on = ["aws_instance.bootstrap", "null_resource.setup-master"]
  connection {
    host = "${element(aws_instance.public-agent.*.private_ip, count.index)}"
    user = "core"
    agent = true
  }
  provisioner "file" {
    source = "./do-install.sh"
    destination = "/tmp/do-install.sh"
  }
  provisioner "remote-exec" {
    inline = "bash /tmp/do-install.sh slave_public"
  }
}
