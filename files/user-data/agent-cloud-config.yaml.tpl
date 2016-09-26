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
            Environment='DOCKER_OPTS=--insecure-registry=${private_subnet_cidr}'
    - name: var-jenkins_nfs.mount
      command: start
      content: |
       [Mount]
       What=${nfs_server_ip}:/home/core/jenkins_nfs
       Where=/var/jenkins_nfs
       Type=nfs
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
        ExecStart=/bin/sh -c "docker run --rm --name %p --privileged -v /var/log/mesos:/var/log/mesos -e "LOGSTASH_URI=${logstash_uri}" ${filebeat_image}"
        ExecStop=/bin/sh -c "docker stop %p"
        RestartSec=5
        Restart=always
        [X-Fleet]
        Global=true
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
    - name: |-
        dcos-stop-systemmd-resolve.service
      command: |-
        start
      content: |
        [Unit]
        Description=Stop system-md resolve
        [Service]
        WorkingDirectory=/tmp
        Type=oneshot
        StandardOutput=journal+console
        StandardError=journal+console
        ExecStart=/usr/bin/systemctl disable systemd-resolved
        ExecStop=/usr/bin/systemctl stop systemd-resolved
        [Install]
        WantedBy=multi-user.target
    - name: docker-cert-script.service
      drop-ins:
        - name: certificate-download-script.sh
          content: |
            #!/bin/bash
            RESPONSE=300;
            RESPONSE=$(curl --write-out "%{http_code}\n" --silent --output /dev/null "${bootstrap_url}/domain.crt")
            if [ "$RESPONSE" = "200" ]; then
               sudo sysctl -w net.netfilter.nf_conntrack_tcp_be_liberal=1
               sudo mkdir --parent /etc/privateregistry/certs/
               sudo mkdir --parent /etc/docker/certs.d/192.168.0.1
               mkdir --parent /tmp/docker-certs
               sudo curl -o /tmp/docker-certs/domain.crt ${bootstrap_url}/domain.crt
               sudo curl -o /tmp/docker-certs/domain.key ${bootstrap_url}/domain.key
               sudo cp /tmp/docker-certs/*  /etc/privateregistry/certs/
               sudo cp /tmp/docker-certs/domain.crt /etc/docker/certs.d/192.168.0.1/ca.crt
               sudo systemctl restart docker
               sleep 1
            fi
    - name: |-
        docker-cert-downloader.service
      command: |-
        start
      content: |
        [Unit]
        Description=Download start script
        After=docker-cert-script.service
        Wants=docker-cert-script.service
        [Service]
        Type=oneshot
        StandardOutput=journal+console
        StandardError=journal+console
        ExecStart=/bin/bash /etc/systemd/system/docker-cert-script.service.d/certificate-download-script.sh
