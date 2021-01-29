FROM ubuntu:20.04
RUN yes | unminimize
RUN apt-get update
RUN apt-get install -y man acl tini
RUN apt-get install -y iputils-ping openssh-server
COPY systemd-random-seed.service /usr/lib/systemd/system/systemd-random-seed.service
COPY cloud.cfg  /etc/cloud/cloud.cfg
COPY wizard_key.pub /home/wizard/.ssh/authorized_keys
COPY bash_profile /home/wizard/.bash_profile
COPY motd /etc/motd
COPY id_rsa.pub /root/.ssh/authorized_keys
COPY build-container.sh /build-container.sh
COPY init.sh /sbin/init
RUN chmod 755 /sbin/init
RUN bash /build-container.sh; rm /build-container.sh

COPY start.sh start.sh

CMD ["bash", "start.sh"]

