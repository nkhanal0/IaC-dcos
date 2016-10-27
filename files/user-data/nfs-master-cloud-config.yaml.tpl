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
            Environment='DOCKER_OPTS=--insecure-registry=${private_subnet_cidr}'
    - name: |-
        filebeat-docker.service
      command: |-
        start
      content: |
        [Unit]
        Description=Filebeat
        After=docker.service
        Requires=docker.service
        [Service]
        TimeoutStartSec=0
        ExecStartPre=-/bin/sh -c "docker kill %p"
        ExecStartPre=-/bin/sh -c "docker rm -f %p 2> /dev/null"
        ExecStartPre=/bin/sh -c "docker pull ${filebeat_image}"
        ExecStartPre=/bin/sh -c "docker run --name %p -d --privileged -v /var/log/mesos:/var/log/mesos -e "LOGSTASH_URI=${logstash_uri}" -e "NODE_TYPE=mesos_master" ${filebeat_image}"
        ExecStart=/bin/sh -c "journalctl --since="now" -f -u dcos-3dt.service -u dcos-3dt.socket -u dcos-adminrouter-reload.service -u dcos-adminrouter-reload.timer -u dcos-adminrouter.service -u dcos-bouncer.service -u dcos-ca.service -u dcos-cfn-signal.service -u dcos-cosmos.service -u dcos-download.service -u dcos-epmd.service -u dcos-exhibitor.service -u dcos-gen-resolvconf.service -u dcos-gen-resolvconf.timer -u dcos-history.service -u dcos-link-env.service -u dcos-logrotate-master.timer -u dcos-marathon.service -u dcos-mesos-dns.service -u dcos-mesos-master.service -u dcos-metronome.service -u dcos-minuteman.service -u dcos-navstar.service -u dcos-networking_api.service -u dcos-secrets.service -u dcos-setup.service -u dcos-signal.service -u dcos-signal.timer -u dcos-spartan-watchdog.service -u dcos-spartan-watchdog.timer -u dcos-spartan.service -u dcos-vault.service -u dcos-logrotate-master.service | docker exec -i filebeat-docker /opt/filebeat/filebeat -v -c /opt/filebeat/filebeat.yml"
        ExecStop=/bin/sh -c "docker stop %p"
        RestartSec=5
        Restart=always
        [X-Fleet]
        Global=true
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
        ExecStart=/usr/bin/docker run --name sysdig-agent --privileged --net host --pid host -e ACCESS_KEY=${sysdig_access_key} -e TAGS=NodeType:Master,dcosName:${dcos_name} -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v /boot:/host/boot:ro sysdig/agent
        ExecStop=/usr/bin/docker stop sysdig-agent
    - name: dcos-config-script.service
      drop-ins:
        - name: config-download-script.sh
          content: |
            #!/bin/bash
            mkdir /tmp/dcos
            RESPONSE=300;
            while [ $RESPONSE -ne 200 ]
            do
            RESPONSE=$(curl --write-out "%{http_code}\n" --silent --output /dev/null "${bootstrap_url}/dcos_install.sh")
            if [ "$RESPONSE" = "200" ]; then
               sudo curl -o /tmp/dcos/dcos_install.sh ${bootstrap_url}/dcos_install.sh
               sleep 1
            fi
            done
    - name: |-
        dcos-config-downloader.service
      content: |
        [Unit]
        Description=Download start script
        After=dcos-config-script.service
        Wants=dcos-config-script.service
        [Service]
        Type=oneshot
        StandardOutput=journal+console
        StandardError=journal+console
        ExecStart=/bin/bash /etc/systemd/system/dcos-config-script.service.d/config-download-script.sh
    - name: |-
        dcos-start-install.service
      command: |-
        start
      content: |
        [Unit]
        Description=Run Install Script
        Requires=dcos-config-downloader.service
        After=dcos-config-downloader.service
        [Service]
        WorkingDirectory=/tmp
        Type=oneshot
        StandardOutput=journal+console
        StandardError=journal+console
        ExecStart=/bin/bash /tmp/dcos/dcos_install.sh ${role}
        [Install]
        WantedBy=multi-user.target
    - name: settimezone.service
      command: start
      content: |
        [Unit]
        Description=Set the time zone
        [Service]
        ExecStart=/usr/bin/timedatectl set-timezone ${dcos_timezone}
        RemainAfterExit=yes
        Type=oneshot
