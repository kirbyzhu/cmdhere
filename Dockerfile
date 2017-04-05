FROM alpine:3.5
RUN \
  apk update && \
  apk upgrade && \
  apk add \
    bash \
    curl \
    dcron \
    dropbear \
    htop \
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
  # hack openrc for docker
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
  echo 'null::respawn:/run.sh' >> /etc/inittab && \
  # add /run.sh for services
  echo -e '#!/bin/ash\n\
/etc/init.d/rsyslog start\n\
/etc/init.d/dcron start\n\
/etc/init.d/dropbear start\n\
exec tail -f /dev/null'\
  > /run.sh && \
  chmod +x /run.sh && \
  # set root password
  echo root:toor | chpasswd

CMD ["/sbin/init"]
