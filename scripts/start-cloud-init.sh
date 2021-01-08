#!/bin/bash
set -e
# kill qemu on exit
trap 'set -e; kill $(jobs -p)' exit

CLOUD_INIT_FILE=$(find . -path "*$1*cloud-init.yaml")
[ -f $CLOUD_INIT_FILE ] || exit

echo "instance-id: $(uuidgen || echo i-abcdefg)" > my-meta-data

IMG=/tmp/my-seed.img
FOCAL=/home/bork/work/images/focal-server-cloudimg-amd64.img
SNAPSHOT=/tmp/snapshot.qcow2
qemu-img create -b $FOCAL -f qcow2 -F qcow2 $SNAPSHOT

cloud-localds $IMG $CLOUD_INIT_FILE my-meta-data

qemu-system-x86_64 --enable-kvm -m 500 \
    -drive file=$SNAPSHOT,format=qcow2 \
    -drive file=$IMG,format=raw \
    -net user,hostfwd=tcp::2222-:22 -net nic \
    -nographic > /dev/null 2>/dev/null &

start=$SECONDS
while ! ssh -p 2222 -o ConnectTimeout=1 -o StrictHostKeyChecking=no -i wizard.key wizard@localhost 'sudo bash setup/run.sh' > /dev/null 2>/dev/null
do
    duration=$(( SECONDS - start ))
    echo "waiting for ssh.. $duration"
    sleep 1
done
#ssh -p 2222 -o ConnectTimeout=1 -o StrictHostKeyChecking=no -i wizard.key wizard@localhost 'sudo rm -rf setup'
ssh -p 2222 -o ConnectTimeout=1 -o StrictHostKeyChecking=no -i wizard.key wizard@localhost
