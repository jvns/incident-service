set -eux

losetup -D
dmsetup remove myoverlay || true
dmsetup remove mybase || true

DEV=/home/bork/work/firecracker-images/base.ext4
sudo e2fsck $DEV
OVERLAY=/home/bork/work/firecracker-images/overlay.ext4

#fallocate -l  1200M $OVERLAY
qemu-img create -f raw $OVERLAY 1200M
OVERLAY_SZ=`blockdev --getsz $OVERLAY`

LOOP=$(losetup --find --show --read-only $DEV)
SZ=`blockdev --getsz $DEV`
printf "0 $SZ linear $LOOP 0\n$SZ $OVERLAY_SZ zero"  | dmsetup create mybase

#e2fsck /dev/mapper/mybase
#mkdir -p mnt
#mount -o ro /dev/mapper/mybase mnt
#ls mnt
#umount /dev/mapper/mybase
#rmdir mnt

LOOP2=$(losetup /dev/loop23 --show $OVERLAY)
echo "0 $OVERLAY_SZ snapshot /dev/mapper/mybase $LOOP2 P 8" | dmsetup create myoverlay


# wrong fs type, bad option, bad superblock on /dev/mapper/mybase,
# missing codepage or helper program, or other error.

