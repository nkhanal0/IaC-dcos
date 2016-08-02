#!/usr/bin/env bash
. ./ips.txt
# Make some config files
cat > config.yaml << FIN
bootstrap_url: http://$BOOTSTRAP:9999
cluster_name: $CLUSTER_NAME
exhibitor_storage_backend: static
log_directory: /genconf/logs
ip_detect_filename: /genconf/ip-detect
master_list:
- $MASTER_00
- $MASTER_01
- $MASTER_02
- $MASTER_03
- $MASTER_04
agent_list:
- $AGENT_00
- $AGENT_01
- $AGENT_02
- $AGENT_03
- $AGENT_04
- $AGENT_05
- $AGENT_06
- $AGENT_07
resolvers:
- 8.8.4.4
- 8.8.8.8
ssh_key_path: '/genconf/ssh_key'
ssh_port: 22
ssh_user: core
superuser_username: kenta
superuser_password_hash: $DCOS_SUPERUSER_PASSWORD_HASH
FIN

cat > ip-detect << FIN
#!/bin/sh
# Example ip-detect script using an external authority
# Uses the AWS Metadata Service to get the node's internal
# ipv4 address
curl -fsSL http://169.254.169.254/latest/meta-data/local-ipv4
FIN
#rm -rf ./ips.txt