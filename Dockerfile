FROM ubuntu:14.04.5

RUN \
  locale-gen en_US.UTF-8 && \
  export TZ=Asia/Shanghai && \
  export TERM=xterm && \
  export HOME=/root && \
  export DEBIAN_FRONTEND=noninteractive && \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y \
    software-properties-common \
    curl \
    git \
    htop \
    unzip \
    vim \
    wget \
    openssh-server && \
  sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
  sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
  sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
  rm -rf /var/lib/apt/lists/* && \
  wget -O /root/.bashrc https://raw.githubusercontent.com/phuslu/cmdhere/master/.bashrc && \
  wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 && \
  chmod +x /usr/local/bin/dumb-init && \
  echo '#!/bin/bash\n\
echo root:Aaa123789 | chpasswd\n\
/etc/init.d/ssh start\n\
exec tail -f /dev/null'\
  > /run.sh && \
  chmod +x /run.sh

ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "/run.sh"]
