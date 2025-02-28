#!/bin/bash -xe
{
  source lib.sh

  MY_CPU_ARCH=$1
  LYSMARINE_VER=$2
  BBN_KIND=$3

  thisArch="debian"
  cpuArch="amd64"
  imageSource="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.9.0-amd64-netinst.iso"

  checkRoot

  # Create caching folder hierarchy to work with this architecture.
  setupWorkSpace $thisArch

  # Download the Debian image
  log "Downloading Debian image from internet."
  myCache=${cacheDir}/$thisArch
  if [ ! -f $myCache/"$(basename $imageSource)" ]; then
    wget -P $myCache/ $imageSource
  fi

  # Create a raw disk image
  log "Creating raw disk image for AMD64 build"
  if [ "$BBN_KIND" == "LITE" ]; then
    imageSize="9216M"  # 9.2G
  else
    imageSize="15488M"  # 15.5G
  fi

  imageName="debian-12.9.0-amd64.img"
  
  # Create a raw disk image if it doesn't exist
  if [ ! -f $myCache/$imageName ]; then
    log "Creating new raw disk image"
    # Create empty disk image
    dd if=/dev/zero of=$myCache/$imageName bs=1M count=1
    truncate -s $imageSize $myCache/$imageName
    
    # Partition the disk
    parted -s $myCache/$imageName mklabel msdos
    parted -s $myCache/$imageName mkpart primary fat32 1MiB 256MiB
    parted -s $myCache/$imageName mkpart primary ext4 256MiB 7G
    parted -s $myCache/$imageName mkpart primary linux-swap 7G 8G
    parted -s $myCache/$imageName mkpart primary ext4 8G 100%
    parted -s $myCache/$imageName set 1 boot on
    
    # Setup loop device
    losetup -f
    loopdevice=$(losetup -f --show $myCache/$imageName)
    partitions=$(kpartx -sav $loopdevice | cut -d' ' -f3)
    loopId=$(echo "$partitions" | grep -oh '[0-9]*' | head -n 1)
    
    # Format partitions
    mkfs.vfat -F32 /dev/mapper/loop${loopId}p1
    mkfs.ext4 -F /dev/mapper/loop${loopId}p2
    mkswap /dev/mapper/loop${loopId}p3
    mkfs.ext4 -F /dev/mapper/loop${loopId}p4
    e2label /dev/mapper/loop${loopId}p4 useroverlay
    
    # Mount partitions
    mkdir -p $myCache/mnt/bootfs
    mkdir -p $myCache/mnt/rootfs
    mount /dev/mapper/loop${loopId}p1 $myCache/mnt/bootfs
    mount /dev/mapper/loop${loopId}p2 $myCache/mnt/rootfs
    
    # Extract Debian base system (using debootstrap)
    apt-get update
    apt-get install -y debootstrap
    debootstrap --arch=amd64 bookworm $myCache/mnt/rootfs http://deb.debian.org/debian
    
    # Create mount points for virtual filesystems
    mkdir -p $myCache/mnt/rootfs/dev/pts
    mkdir -p $myCache/mnt/rootfs/proc
    mkdir -p $myCache/mnt/rootfs/sys
    
    # Mount virtual filesystems for chroot
    mount -o bind /dev $myCache/mnt/rootfs/dev
    mount -o bind /dev/pts $myCache/mnt/rootfs/dev/pts
    mount -o bind /proc $myCache/mnt/rootfs/proc
    mount -o bind /sys $myCache/mnt/rootfs/sys
    
    # Basic system configuration
    mkdir -p $myCache/mnt/rootfs/boot
    mount --bind $myCache/mnt/bootfs $myCache/mnt/rootfs/boot
    
    # Generate fstab
    cat > $myCache/mnt/rootfs/etc/fstab << EOF
/dev/sda1  /boot         vfat   defaults        0  2
/dev/sda2  /             ext4   defaults        0  1
/dev/sda3  none          swap   sw              0  0
/dev/sda4  /useroverlay  ext4   defaults        0  2
EOF
    
    # Configure the system
    chroot $myCache/mnt/rootfs /bin/bash -xe << EOF
apt-get update
sed -i 's/deb http:\/\/deb.debian.org\/debian bookworm main/deb http:\/\/deb.debian.org\/debian bookworm main contrib non-free non-free-firmware/g' /etc/apt/sources.list
apt-get update
apt-get install -y linux-image-amd64 grub-pc network-manager sudo iproute2 firmware-linux-free firmware-misc-nonfree
EOF
    
    # Install bootloader
    LOOP_DEVICE_PATH=$loopdevice
    BOOT_PARTITION=/dev/mapper/loop${loopId}p1
    ROOT_PARTITION=/dev/mapper/loop${loopId}p2
    
    # Create a device.map file to help GRUB find the right device
    mkdir -p $myCache/mnt/rootfs/boot/grub
    cat > $myCache/mnt/rootfs/boot/grub/device.map << EOF
(hd0) ${LOOP_DEVICE_PATH}
(hd0,1) ${BOOT_PARTITION}
(hd0,2) ${ROOT_PARTITION}
EOF
    
    # Create a custom configuration for GRUB
    cat > $myCache/mnt/rootfs/etc/default/grub << EOF
GRUB_DISTRIBUTOR="Lysmarine"
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="root=/dev/sda2"
EOF
    
    chroot $myCache/mnt/rootfs /bin/bash -xe << EOF
# Make sure grub can find the correct device
mkdir -p /boot/grub
grub-install --boot-directory=/boot --force ${LOOP_DEVICE_PATH}
update-grub
EOF
    
    # Clean up mounts
    umount $myCache/mnt/rootfs/boot
    umount $myCache/mnt/rootfs/dev/pts
    umount $myCache/mnt/rootfs/dev
    umount $myCache/mnt/rootfs/proc
    umount $myCache/mnt/rootfs/sys
    umount $myCache/mnt/rootfs
    umount $myCache/mnt/bootfs
    
    # Detach loop device
    kpartx -d $loopdevice
    losetup -d $loopdevice
  fi

  # Copy image file to work folder
  cp -fv $myCache/$imageName ./work/$thisArch/$imageName

  # Mount the image and make the binds required to chroot
  mountImageFile $thisArch ./work/$thisArch/$imageName

  # Copy the lysmarine scripts
  addLysmarineScripts $thisArch

  mkRoot=work/${thisArch}/rootfs
  ls -l $mkRoot

  mkdir -p ./cache/${thisArch}/stageCache
  mkdir -p $mkRoot/install-scripts/stageCache
  mkdir -p /run/shm
  mkdir -p $mkRoot/run/shm
  mount -o bind /etc/resolv.conf $mkRoot/etc/resolv.conf
  mount -o bind /dev $mkRoot/dev
  mount -o bind /sys $mkRoot/sys
  mount -o bind /proc $mkRoot/proc
  mount -o bind /tmp $mkRoot/tmp
  mount --rbind $myCache/stageCache $mkRoot/install-scripts/stageCache
  mount --rbind /run/shm $mkRoot/run/shm
  
  # Run installation scripts
  chroot $mkRoot /bin/bash -xe <<EOF
    set -x; set -e; cd /install-scripts; export LMBUILD="debian"; export BBN_KIND="$BBN_KIND"; ls; chmod +x *.sh; ./install.sh 0 2 4 6 8 a; exit
EOF

  # Unmount
  umountImageFile $thisArch ./work/$thisArch/$imageName

  ls -l ./work/$thisArch/$imageName

  # Renaming the OS and moving it to the release folder
  if [ "$BBN_KIND" == "LITE" ]; then
    BBN_IMG=lysmarine-bbn-lite-bookworm_"${LYSMARINE_VER}"-${thisArch}-${cpuArch}.img
  else
    BBN_IMG=lysmarine-bbn-full-bookworm_"${LYSMARINE_VER}"-${thisArch}-${cpuArch}.img
  fi
  cp -v -l ./work/$thisArch/$imageName ./release/$thisArch/"$BBN_IMG"

  exit 0
} 