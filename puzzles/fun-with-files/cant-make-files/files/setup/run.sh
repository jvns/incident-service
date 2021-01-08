set -e
i=0
sudo mkdir -p /opt/files
sudo chmod 777 /opt/files
cd /opt/files
dd if=/dev/zero of=masterfile bs=10000 count=1000
split -b 5 -a 30 ./masterfile
