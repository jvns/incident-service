FROM ubuntu:20.04
RUN yes | unminimize
RUN apt-get update
RUN apt-get install -y iputils-ping openssh-server man acl
RUN apt-get install -y strace curl wget tcpdump
RUN apt-get install -y less sudo mosh dnsutils net-tools
RUN useradd -ms /bin/bash wizard
RUN echo 'wizard ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers
#RUN adduser wizard sudo
COPY wizard_key.pub /home/wizard/.ssh/authorized_keys
RUN chmod 644 /home/wizard/.ssh/authorized_keys
COPY bash_profile /home/wizard/.bash_profile
COPY motd /etc/motd
RUN echo '' > /etc/legal
RUN rm -f /etc/update-motd.d/*
RUN rm -f /etc/legal
RUN chown wizard:wizard /home/wizard
COPY puzzles /puzzles
COPY start.sh start.sh

CMD ["bash", "start.sh"]

