#!/bin/bash -x 
export DIBUILD 
ISO=/opt/cd-image
set -e

# Copy the old ISO to the new iso.
#rsync -a /opt/old/iso_orig/iso $ISO

# Unpack iso at $ISO
sudo rm -fr $ISO/dists/xenial/Release.gpg
# Keeping the old kernel there
#sudo rm -fr $ISO/pool/main/l/linux-hwe/* 

# Copying new kernel debs and udebs
sudo cp /opt/kernel/* $ISO/pool/main/l/linux-hwe/
# copying all.
sudo cp /opt/build/meta/*deb $ISO/pool/main/l/linux-meta-hwe

# Update keyring
cd /opt/build/keyring/*/
gpg --export FBB75451 437D05B5 C0B21F32 EFE21092 FC78776D  > ubuntu-archive-keyring.gpg
dpkg-buildpackage -rfakeroot -m"Breno Leitao <breno.leitao@gmail.com>" -kFC78776D


sudo rm -fr $ISO/pool/main/u/ubuntu-keyring/*
sudo cp /opt/build/keyring/*deb $ISO/./pool/main/u/ubuntu-keyring/

# Building debian installer
if [ -n "$DIBUILD" ]
then
	cd /opt/build/di/debian-installer-20101020ubuntu451.16/build/
	make reallyclean
	make build_hwe-cdrom
fi

# copy the kernel
sudo cp /opt/build/di/debian-installer-20101020ubuntu451.16/build/dest/hwe-cdrom/vmlinux $ISO/install/hwe-vmlinux
sudo cp /opt/build/di/debian-installer-20101020ubuntu451.16/build/dest/hwe-netboot/ubuntu-installer/ppc64el/vmlinux $ISO/install
sudo cp /opt/build/di/debian-installer-20101020ubuntu451.16/build/dest/hwe-netboot/ubuntu-installer/ppc64el/vmlinux $ISO/install/hwe-netboot/ubuntu-installer/ppc64el/vmlinux

# copy initrd
sudo cp /opt/build/di/debian-installer-20101020ubuntu451.16/build/dest/hwe-cdrom/initrd.gz $ISO/install/hwe-initrd.gz
sudo cp /opt/build/di/debian-installer-20101020ubuntu451.16/build/dest/hwe-netboot/ubuntu-installer/ppc64el/initrd.gz $ISO/install
sudo cp /opt/build/di/debian-installer-20101020ubuntu451.16/build/dest/hwe-netboot/ubuntu-installer/ppc64el/initrd.gz $ISO/install/hwe-netboot/ubuntu-installer/ppc64el/initrd.gz

# Copying twice?
#sudo cp /opt/build/di/debian-installer-20101020ubuntu451.16/build/tmp/hwe-cdrom/vmlinux $ISO/install/hwe-netboot/ubuntu-installer/ppc64el
#sudo cp /opt/build/di/debian-installer-20101020ubuntu451.16/build/tmp/hwe-cdrom/initrd.gz $ISO/install/hwe-netboot/ubuntu-installer/ppc64el

# Running ftparchive
cd /opt/apt-ftparchive
sudo ./build_repo.sh

# Unsquashing
cd  /opt
sudo rm -fr /opt/squashfs-root
sudo rm -fr $ISO/install/filesystem.squashfs
sudo unsquashfs old/iso_orig/iso/install/filesystem.squashfs

# update keyring
sudo cp /opt/build/keyring/ubuntu-keyring-2012.05.19ubuntu1/keyrings/ubuntu-archive-keyring.gpg /opt/squashfs-root/usr/share/keyrings/ubuntu-archive-keyring.gpg
sudo cp /opt/build/keyring/ubuntu-keyring-2012.05.19ubuntu1/keyrings/ubuntu-archive-keyring.gpg /opt/squashfs-root/etc/apt/trusted.gpg   
sudo cp /opt/build/keyring/ubuntu-keyring-2012.05.19ubuntu1/keyrings/ubuntu-archive-keyring.gpg /opt/squashfs-root/var/lib/apt/keyrings/ubuntu-archive-keyring.gpg

# Squash again
sudo mksquashfs squashfs-root $ISO/install/filesystem.squashfs
cd squashfs-root
sudo du -sx --block-size=1 ./ | cut -f1 > /tmp/a
sudo cp /tmp/a $ISO/install/filesystem.size
cd $ISO/install
sudo rm -fr filesystem.squashfs.gpg
sudo gpg --armor --detach-sign -o filesystem.squashfs.gpg filesystem.squashfs

# Generate the ISO
cd /opt
sudo rm -fr test.iso
sudo grub-mkrescue --output=test.iso $ISO/

scp test.iso brenohl@10.1.0.1:/home/brenohl/iso
