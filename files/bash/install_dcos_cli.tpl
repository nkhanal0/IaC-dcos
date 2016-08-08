mkdir -p ~/dcos-cli && cd dcos-cli &&
  curl -O https://bootstrap.pypa.io/get-pip.py &&
  sudo python get-pip.py &&
  sudo pip install virtualenv &&
  curl -O https://downloads.mesosphere.com/dcos-cli/install.sh &&
  echo yes | bash ./install.sh . https://${master_elb_dns_name} &&
  source ./bin/env-setup