#!/usr/bin/env bash
. ./ips.txt
# Make some config files
cat > config.yaml << FIN
bootstrap_url: http://$BOOTSTRAP:9999
cluster_name: $CLUSTER_NAME
exhibitor_storage_backend: static
log_directory: /genconf/logs
ip_detect_filename: /genconf/ip-detect
master_discovery: static
master_list:
- $MASTER_00
- $MASTER_01
- $MASTER_02
- $MASTER_03
- $MASTER_04
resolvers:
- 8.8.4.4
- 8.8.8.8
ssh_key_path: '/genconf/ssh_key'
ssh_port: 22
ssh_user: core
oauth_enabled: 'false'
superuser_username: $DCOS_USERNAME
FIN

cat > ip-detect << FIN
#!/bin/sh
# Example ip-detect script using an external authority
# Uses the AWS Metadata Service to get the node's internal
# ipv4 address
curl -fsSL http://169.254.169.254/latest/meta-data/local-ipv4
FIN
rm -rf ./ips.txt
