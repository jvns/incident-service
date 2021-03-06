set -eux

# build docker container
IMG_ID=$(docker build -q .)
CONTAINER_ID=$(docker run -td $IMG_ID /bin/bash)

# build image

MOUNTDIR=mnt
FS=/home/bork/work/firecracker-images/base.ext4

# dumb tricks to make sure dest is empty
umount $MOUNTDIR || true
mkdir -p $MOUNTDIR
rmdir $MOUNTDIR
mkdir $MOUNTDIR
rm $FS
qemu-img create -f raw $FS 800M
chmod 644 $FS
mkfs.ext4 $FS
e2fsck $FS
mount $FS $MOUNTDIR
chmod 777 mnt
docker cp -a $CONTAINER_ID:/ $MOUNTDIR
chown -R 1000:1000 $MOUNTDIR/home/wizard # hmm
chown -R 6:0 $MOUNTDIR/var/cache/man # hmm

umount $MOUNTDIR

docker kill $CONTAINER_ID
rmdir mnt
