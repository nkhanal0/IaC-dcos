/* EC2 */
resource "aws_instance" "nfs-server" {
  ami = "${lookup(var.coreos_amis, var.aws_region)}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  instance_type = "${var.instance_type["nfs-server"]}"
  key_name = "${var.key_pair_name}"
  vpc_security_group_ids = ["${aws_security_group.private.id}"]
  subnet_id = "${aws_subnet.private-primary.id}"
  source_dest_check = false
  user_data = "${data.template_file.nfs_server_user_data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.s3_profile_master.name}"

  connection {
    user = "core"
    agent = true
  }

  root_block_device {
    volume_size = "${var.nfs_server_disk_size}"
    delete_on_termination = true
  }

  tags {
    Name = "${var.pre_tag}-NFS-Server-${var.post_tag}"
    Service = "${var.tag_service}"
    Environment = "${var.tag_environment}"
    Version = "${var.tag_version}"
  }
}

/* Cloud-Config */
data "template_file" "nfs_server_user_data" {
  template = "${file("${path.module}/files/user-data/nfs-server-cloud-config.yaml.tpl")}"

  vars {
    private_subnet_cidr = "${var.private_primary_subnet_cidr}"
    nfs_access_address = "${var.nfs_access_address}"
    dcos_timezone = "${var.dcos_timezone}"
    sysdig_access_key = "${var.sysdig_access_key}"
    dcos_name = "${var.pre_tag}-${var.post_tag}"
  }
}
