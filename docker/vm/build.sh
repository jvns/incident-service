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
qemu-img create -f raw $FS 800M
mkfs.ext4 $FS
mount $FS $MOUNTDIR
chmod 777 mnt
docker cp $CONTAINER_ID:/ $MOUNTDIR

umount $MOUNTDIR
rmdir mnt
