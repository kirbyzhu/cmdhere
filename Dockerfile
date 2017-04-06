FROM alpine:3.5
RUN \
  apk update && \
  apk upgrade && \
  apk add \
    bash \
    curl \
    dcron \
    dropbear \
    shadow \
    procps \
    logrotate \
    openrc \
    openssh-client \
    openssh-sftp-server \
    openssl \
    rsyslog \
    xz && \
  rm -rf /var/cache/apk/* && \
  # root user settings
  curl https://phuslu.github.io/bashrc >/root/.profile  && \
  touch /var/log/lastlog && \
  sed -i 's#root:/bin/ash#root:/bin/bash#' /etc/passwd && \
  # hack for golang
  mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 && \
  # hack openrc for docker
  echo 'null::respawn:/usr/bin/tail -f /dev/null' >> /etc/inittab && \
  sed -i '/tty/d' /etc/inittab && \
  sed -i 's/#rc_sys=""/rc_sys="docker"/g' /etc/rc.conf && \
  echo 'rc_provide="loopback net"' >> /etc/rc.conf && \
  sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf && \
  sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname && \
  sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh && \
  sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh && \
  rm -f /etc/init.d/hwclock \
        /etc/init.d/hwdrivers \
        /etc/init.d/modules \
        /etc/init.d/modules-load \
        /etc/init.d/modloop && \
  # add auto-start services
  rc-update add rsyslog default && \
  rc-update add dcron default && \
  rc-update add dropbear default && \
  # set root password
  echo root:toor | chpasswd

CMD ["/sbin/init"]
