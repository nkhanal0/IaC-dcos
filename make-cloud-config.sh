#!/usr/bin/env bash

cat > agent-cloud-config.yaml << 'EOF'
#cloud-config

coreos:
  etcd2:
    discovery: https://discovery.etcd.io/a8b57a19287d1030ff94693ad5fab642
    advertise-client-urls: http://$private_ipv4:2379,http://$private_ipv4:4001
    initial-advertise-peer-urls: http://$private_ipv4:2380
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    listen-peer-urls: http://$private_ipv4:2380
  fleet:
    public-ip: $private_ipv4   # used for fleetctl ssh command
    metadata: "mesos-node=agent"
  units:
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start
    - name: docker.service
      drop-ins:
        - name: 50-insecure-registry.conf
          content: |
            [Service]
            Environment='DOCKER_OPTS=--insecure-registry=PRIVATE_SUBNET_CIDR'
    - name: var-jenkins_nfs.mount
      command: start
      content: |
       [Mount]
       What=NFS_SERVER_IP:/home/core/jenkins_nfs
       Where=/var/jenkins_nfs
       Type=nfs
EOF

cat > master-cloud-config.yaml << 'EOF'
#cloud-config

coreos:
  etcd2:
    # generate a new token for each unique cluster from https://discovery.etcd.io/new:
    discovery: https://discovery.etcd.io/a8b57a19287d1030ff94693ad5fab642
    # multi-region deployments, multi-cloud deployments, and Droplets without
    # private networking need to use $public_ipv4:
    advertise-client-urls: http://$private_ipv4:2379,http://$private_ipv4:4001
    initial-advertise-peer-urls: http://$private_ipv4:2380
    # listen on the official ports 2379, 2380 and one legacy port 4001:
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    listen-peer-urls: http://$private_ipv4:2380
  fleet:
    public-ip: $private_ipv4   # used for fleetctl ssh command
    metadata: "mesos-node=master"
  units:
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start
    - name: docker.service
      drop-ins:
        - name: 50-insecure-registry.conf
          content: |
            [Service]
            Environment='DOCKER_OPTS=--insecure-registry=PRIVATE_SUBNET_CIDR'
EOF

cat > nfs-master-cloud-config.yaml << 'EOF'
#cloud-config
write-files:
     - path: "/home/core/jenkins_nfs/readme.txt"
       permissions: "777"
       owner: "root"
       content: |
         Successful nfs mounting.
write-files:
     - path: "/etc/exports"
       permissions: "777"
       owner: "root"
       content: |
         /home/core/jenkins_nfs     NFS_ACCESS_ADDRESS(rw,async,no_subtree_check,no_root_squash)
coreos:
  etcd2:
    # generate a new token for each unique cluster from https://discovery.etcd.io/new:
    discovery: https://discovery.etcd.io/a8b57a19287d1030ff94693ad5fab642
    # multi-region deployments, multi-cloud deployments, and Droplets without
    # private networking need to use $public_ipv4:
    advertise-client-urls: http://$private_ipv4:2379,http://$private_ipv4:4001
    initial-advertise-peer-urls: http://$private_ipv4:2380
    # listen on the official ports 2379, 2380 and one legacy port 4001:
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    listen-peer-urls: http://$private_ipv4:2380
  fleet:
    public-ip: $private_ipv4   # used for fleetctl ssh command
    metadata: "mesos-node=master"
  units:
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start
    - name: nfsd.service
      command: start
    - name: docker.service
      drop-ins:
        - name: 50-insecure-registry.conf
          content: |
            [Service]
            Environment='DOCKER_OPTS=--insecure-registry=PRIVATE_SUBNET_CIDR'
EOF