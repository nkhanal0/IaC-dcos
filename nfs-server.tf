resource "null_resource" "nfs_server" {
  connection {
    host = "${aws_instance.bootstrap.private_ip}"
    user = "centos"
    agent = true
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install nfs-utils",
      "sudo systemctl enable nfs-server.service",
      "sudo systemctl start nfs-server.service",
      "sudo mkdir /var/nfs",
      "sudo chown -R root /var/nfs",
      "sudo chmod 777 /var/nfs",
      "echo '/var/nfs ${var.nfs_access_address}(rw,async,no_subtree_check,no_root_squash)' | sudo tee /etc/exports",
      "sudo exportfs -a"
    ]
  }
}
