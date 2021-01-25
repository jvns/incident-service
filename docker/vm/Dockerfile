FROM ubuntu:20.04
COPY id_rsa.pub /root/.ssh/authorized_keys
RUN apt-get update
RUN apt-get install -y iputils-ping
RUN apt-get install -y init
RUN apt-get install -y openssh-server
COPY systemd-random-seed.service /usr/lib/systemd/system/systemd-random-seed.service
RUN chmod 644 /root/.ssh/authorized_keys
COPY cloud.cfg  /etc/cloud/cloud.cfg
RUN apt-get install -y man
RUN apt-get install -y acl
RUN yes | unminimize
RUN useradd -ms /bin/bash wizard
COPY wizard_key.pub /home/wizard/.ssh/authorized_keys
RUN chmod 644 /home/wizard/.ssh/authorized_keys
RUN chown wizard:wizard /home/wizard/.ssh/authorized_keys
COPY bash_profile /home/wizard/.bash_profile
COPY motd /etc/motd
RUN systemctl set-default -f multi-user.target
RUN systemctl mask getty@tty1.service
RUN systemctl mask getty.target
RUN systemctl mask dbus.socket
RUN systemctl mask systemd-timesyncd.service
RUN systemctl mask systemd-random-seed.service
RUN echo '' > /etc/legal
RUN rm -f /etc/update-motd.d/*
RUN rm -f /etc/legal
RUN echo 4 > /blah

COPY start.sh start.sh

CMD ["bash", "start.sh"]

