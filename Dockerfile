FROM debian:testing
RUN \
  export TERM=xterm && \
  export HOME=/root && \
  export DEBIAN_FRONTEND=noninteractive && \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y \
    software-properties-common \
    locales \
    anacron \
    rsyslog \
    logrotate \
    lsb \
    bash-completion \
    command-not-found \
    ssh-import-id \
    curl \
    htop \
    make \
    lrzsz \
    unzip \
    zip \
    vim \
    wget \
    sudo \
    netcat \
    net-tools \
    socat \
    screen \
    tmux \
    openssh-server && \
  echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale && \
  echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && \
  dpkg-reconfigure -f noninteractive locales && \
  apt-file update && \
  update-command-not-found && \
  sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
  sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
  sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
  rm -rf /var/lib/apt/lists/* && \
  wget -O /root/.bashrc https://raw.githubusercontent.com/phuslu/cmdhere/master/.bashrc && \
  wget -O /root/.z.sh https://raw.githubusercontent.com/rupa/z/master/z.sh && \
  wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 && \
  chmod +x /usr/local/bin/dumb-init && \
  echo root:Aaa123789 | chpasswd && \
  echo '#!/bin/bash\n\
service rsyslog start\n\
service cron start\n\
service anacron start\n\
service ssh start\n\
test -x /home/init.sh && /home/init.sh start\n\
exec -a /usr/local/bin/dumb-idle tail -f </dev/null'\
  > /run.sh && \
  chmod +x /run.sh

ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "/run.sh"]
