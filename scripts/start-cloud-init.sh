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

qemu-system-x86_64 --enable-kvm -m 1024 \
    -drive file=$SNAPSHOT,format=qcow2 \
    -drive file=$IMG,format=raw \
    -net user,hostfwd=tcp::2222-:22 -net nic \
    -nographic > out 2>out &

SSH_OPTIONS="-p 2222 -i wizard.key -o UserKnownHostsFile=/dev/null -o ConnectTimeout=1 -o StrictHostKeyChecking=no"

start=$SECONDS
while ! ssh $SSH_OPTIONS wizard@localhost 'python3 /usr/local/bin/started_up'
do
    duration=$(( SECONDS - start ))
    echo "waiting for ssh.. $duration"
    sleep 1
done
ssh $SSH_OPTIONS wizard@localhost
