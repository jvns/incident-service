mkdir -p /run/sshd
echo $FLY_PUBLIC_IP
/usr/sbin/sshd -D
