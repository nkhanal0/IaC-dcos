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
         /home/core/jenkins_nfs     ${nfs_access_address}(rw,async,no_subtree_check,no_root_squash)
coreos:
  etcd2:
    discovery: https://discovery.etcd.io/a8b57a19287d1030ff94693ad5fab642
    advertise-client-urls: http://$private_ipv4:2379,http://$private_ipv4:4001
    initial-advertise-peer-urls: http://$private_ipv4:2380
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    listen-peer-urls: http://$private_ipv4:2380
  fleet:
    public-ip: $private_ipv4
    metadata: "mesos-node=nfs-server"
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
            Environment='DOCKER_OPTS=--insecure-registry=${private_subnet_cidr}'
    - name: |-
        sysdig-agent.service
      command: |-
        start
      content: |
        [Unit]
        Description=Sysdig Cloud Agent
        After=docker.service
        Requires=docker.service
        [Service]
        TimeoutStartSec=0
        ExecStartPre=-/usr/bin/docker kill sysdig-agent
        ExecStartPre=-/usr/bin/docker rm sysdig-agent
        ExecStartPre=/usr/bin/docker pull sysdig/agent
        ExecStart=/usr/bin/docker run --name sysdig-agent --privileged --net host --pid host -e ACCESS_KEY=${sysdig_access_key} -e TAGS=NodeType:NFS-server,dcosName:${dcos_name} -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v /boot:/host/boot:ro sysdig/agent
        ExecStop=/usr/bin/docker stop sysdig-agent
    - name: settimezone.service
      command: start
      content: |
        [Unit]
        Description=Set the time zone
        [Service]
        ExecStart=/usr/bin/timedatectl set-timezone ${dcos_timezone}
        RemainAfterExit=yes
        Type=oneshot
