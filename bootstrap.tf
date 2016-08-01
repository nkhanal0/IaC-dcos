resource "aws_instance" "bootstrap" {
  ami = "${lookup(var.centos_amis, var.aws_region)}"
  availability_zone = "${var.aws_region}a"
  instance_type = "${var.instance_type.bootstrap}"
  key_name = "${var.key_pair_name}"
  vpc_security_group_ids = ["${aws_security_group.private.id}"]
  subnet_id = "${aws_subnet.availability-zone-private.id}"
  source_dest_check = false
  depends_on = ["aws_instance.master", "aws_instance.agent", "aws_instance.public-agent"]
  tags {
    Name = "${var.pre_tag}-Bootstrap-${var.post_tag}"
  }
  connection {
    user = "centos"
    agent = true
  }
  root_block_device {
    volume_size = "10"
    delete_on_termination = true
  }
  provisioner "local-exec" {
    command = "rm -rf ./do-install.sh"
  }
  provisioner "local-exec" {
    command = "echo BOOTSTRAP=\"${aws_instance.bootstrap.private_ip}\" >> ips.txt"
  }
  provisioner "local-exec" {
    command = "echo CLUSTER_NAME=\"${var.dcos_cluster_name}\" >> ips.txt"
  }
  provisioner "local-exec" {
    command = "echo DCOS_SUPERUSER_PASSWORD_HASH=\"$(cat secret_hash)\" >>  ips.txt"
  }
  provisioner "local-exec" {
    command = "echo 77faa1f1-80aa-4a74-7bd1-53e90b8979c5 > UUID"
  }
  provisioner "remote-exec" {
    inline = [
      "curl -O https://downloads.mesosphere.com/dcos/stable/dcos_generate_config.ee.sh",
      "mkdir $HOME/genconf"
    ]
  }
  provisioner "local-exec" {
    command = "./make-files.sh"
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
      "sudo service docker start"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo bash $HOME/dcos_generate_config.ee.sh",
      "sudo docker run -d -p 9999:80 -v $HOME/genconf/serve:/usr/share/nginx/html:ro nginx 2>/dev/null"
    ]
  }
}