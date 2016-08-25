data "template_file" "public_agent_user_data" {
  template = "${file(format("%s/files/user-data/agent-cloud-config.yaml.tpl", path.module))}"

  vars {
    bootstrap_url = "http://${aws_instance.bootstrap.private_ip}:9999"
    private_subnet_cidr = "${var.private_subnet_cidr}"
    nfs_server_ip = "${aws_instance.master.0.private_ip}"
    role = "slave_public"
    logstash_uri = "${aws_elb.logstash.dns_name}:80"
    filebeat_image = "${var.filebeat_docker_image}"
  }
}
