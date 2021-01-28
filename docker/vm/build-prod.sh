set -eux
cd /images
docker pull jvns/game:base
CONTAINER_ID=$(docker run -td jvns/game:base)

# build image

MOUNTDIR=mnt
FS=/images/base.ext4

# dumb tricks to make sure dest is empty
umount $MOUNTDIR || true
mkdir -p $MOUNTDIR
rmdir $MOUNTDIR
mkdir $MOUNTDIR
qemu-img create -f raw $FS 800M
chmod 644 $FS
mkfs.ext4 $FS
e2fsck $FS
mount $FS $MOUNTDIR
chmod 777 mnt
docker cp $CONTAINER_ID:/ $MOUNTDIR
chown -R 1000:1000 $MOUNTDIR/home/wizard

umount $MOUNTDIR
rmdir mnt
docker kil $CONTAINER_ID
