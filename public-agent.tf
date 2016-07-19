resource "aws_instance" "public-agent" {
  depends_on = ["aws_instance.master"]
  ami = "${lookup(var.amis, var.aws_region)}"
  availability_zone = "${var.aws_region}a"
  instance_type = "m3.2xlarge"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = [
    "${aws_security_group.private.id}"]
  subnet_id = "${aws_subnet.availability-zone-private.id}"
  source_dest_check = false
  count = "${var.dcos_public_agent_count}"
  user_data = "${file("agent-cloud-config.yaml")}"
  connection {
    user = "core"
    agent = false
    private_key = "${file(var.aws_key_path)}"
  }
  root_block_device {
    volume_size = "${var.dcos_agent_disk_size}"
  }
  tags {
    Name = "${format("${var.pre_tag}-Public-Agent-%d-${var.post_tag}", count.index + 1)}"
  }
  provisioner "local-exec" {
    command = "echo ${format("AGENT_%02d", count.index)}=\"${self.private_ip}\" >> ips.txt"
  }
  provisioner "local-exec" {
    command = "./make-certs.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo sysctl -w net.netfilter.nf_conntrack_tcp_be_liberal=1",
      "sudo mkdir --parent /etc/privateregistry/certs/",
      "sudo mkdir --parent /etc/docker/certs.d/192.168.0.1"
    ]
  }
  provisioner "file" {
    source = "./certs/domain.crt"
    destination = "~/domain.crt"
  }
  provisioner "file" {
    source = "./certs/domain.key"
    destination = "~/domain.key"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo cp ~/domain.* /etc/privateregistry/certs/",
      "sudo cp ~/domain.crt /etc/docker/certs.d/192.168.0.1/ca.crt",
      "sudo systemctl restart docker"
    ]
  }
}

resource "null_resource" "setup-public-agent" {
  count = "${var.dcos_public_agent_count}"
  depends_on = ["aws_instance.bootstrap", "null_resource.setup-master"]
  connection {
    host = "${element(aws_instance.public-agent.*.private_ip, count.index)}"
    user = "core"
    agent = false
    private_key = "${file(var.aws_key_path)}"
  }
  provisioner "file" {
    source = "./do-install.sh"
    destination = "/tmp/do-install.sh"
  }
  provisioner "remote-exec" {
    inline = "bash /tmp/do-install.sh slave_public"
  }
}
