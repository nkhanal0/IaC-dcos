resource "null_resource" "nfs-server-setup" {
  connection {
    host = "${null_resource.nfs_server_ip.triggers.value}"
    user = "core"
    agent = true
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir /home/core/jenkins_nfs && echo 'Successful nfs mounting' > /home/core/jenkins_nfs/readme.txt",
      "echo '/home/core/jenkins_nfs ${var.nfs_access_address}(rw,async,no_subtree_check,no_root_squash)' > /tmp/exports",
      "sudo cp /tmp/exports /etc/exports",
      "sudo systemctl start nfsd"
    ]
  }
}

resource "null_resource" "nfs_server_ip" {
  triggers = {
    value = "${element(split(",", trimspace(null_resource.master_ips.triggers.value)), 0)}"
  }
}
