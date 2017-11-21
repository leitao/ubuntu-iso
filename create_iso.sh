#!/bin/bash -x 

# Copyright Breno Leitao <leitao@debian.org>

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version
# 2 of the License

# Purpose: 
# Script to create an ISO IMAGE in Ubuntu with a newer custom kernel.

# Parameters:
#
# I use This script inside /opt where I have the old ISO image at $OLDISO.
# I also have a new KEYRING package built at $KEYRING
# The new DI recompiled with the new kernel should be at $DI
# and the new kernel packages should be a $kernel

export DIBUILD 
OPT=/opt
ISO=$OPT/cd-image
OLDISO=$OPT/old/iso_orig/iso
KEYRING=$OPT/build/keyring
DI=$OPT/build/di/debian-installer-20101020ubuntu451.16
META=$OPT/build/meta
KERNEL=$OPT/kernel

set -e

# Copy the old ISO to the new iso.
# rsync -a $OLDISO $ISO

# Unpack iso at $ISO
sudo rm -fr $ISO/dists/xenial/Release.gpg
# Keeping the old kernel there
#sudo rm -fr $ISO/pool/main/l/linux-hwe/* 

# Copying new kernel debs and udebs
sudo cp $KERNEL/* $ISO/pool/main/l/linux-hwe/
# copying all.
sudo cp $META/*deb $ISO/pool/main/l/linux-meta-hwe

# Update keyring
cd $KEYRING/*/
gpg --export FBB75451 437D05B5 C0B21F32 EFE21092 FC78776D  > ubuntu-archive-keyring.gpg
dpkg-buildpackage -rfakeroot -m"Breno Leitao <breno.leitao@gmail.com>" -kFC78776D

sudo rm -fr $ISO/pool/main/u/ubuntu-keyring/*
sudo cp $KEYRING/*deb $ISO/./pool/main/u/ubuntu-keyring/

# Building debian installer
if [ -n "$DIBUILD" ]
then
	cd $DI/build/
	make reallyclean
	make build_hwe-cdrom
fi

# copy the kernel
sudo cp $DI/build/dest/hwe-cdrom/vmlinux $ISO/install/hwe-vmlinux
sudo cp $DI/build/dest/hwe-netboot/ubuntu-installer/ppc64el/vmlinux $ISO/install
sudo cp $DI/build/dest/hwe-netboot/ubuntu-installer/ppc64el/vmlinux $ISO/install/hwe-netboot/ubuntu-installer/ppc64el/vmlinux

# copy initrd
sudo cp $DI/build/dest/hwe-cdrom/initrd.gz $ISO/install/hwe-initrd.gz
sudo cp $DI/build/dest/hwe-netboot/ubuntu-installer/ppc64el/initrd.gz $ISO/install
sudo cp $DI/build/dest/hwe-netboot/ubuntu-installer/ppc64el/initrd.gz $ISO/install/hwe-netboot/ubuntu-installer/ppc64el/initrd.gz

# Copying twice?
#sudo cp $DI/build/tmp/hwe-cdrom/vmlinux $ISO/install/hwe-netboot/ubuntu-installer/ppc64el
#sudo cp $DI/build/tmp/hwe-cdrom/initrd.gz $ISO/install/hwe-netboot/ubuntu-installer/ppc64el

# Running ftparchive
cd $OPT/apt-ftparchive
sudo ./build_repo.sh

# Unsquashing
cd  $OPT
sudo rm -fr $OPT/squashfs-root
sudo rm -fr $ISO/install/filesystem.squashfs
sudo unsquashfs old/iso_orig/iso/install/filesystem.squashfs

# update keyring
sudo cp $KEYRING/ubuntu-keyring-2012.05.19ubuntu1/keyrings/ubuntu-archive-keyring.gpg $OPT/squashfs-root/usr/share/keyrings/ubuntu-archive-keyring.gpg
sudo cp $KEYRING/ubuntu-keyring-2012.05.19ubuntu1/keyrings/ubuntu-archive-keyring.gpg $OPT/squashfs-root/etc/apt/trusted.gpg   
sudo cp $KEYRING/ubuntu-keyring-2012.05.19ubuntu1/keyrings/ubuntu-archive-keyring.gpg $OPT/squashfs-root/var/lib/apt/keyrings/ubuntu-archive-keyring.gpg

# Squash again
sudo mksquashfs squashfs-root $ISO/install/filesystem.squashfs
cd squashfs-root
sudo du -sx --block-size=1 ./ | cut -f1 > /tmp/a
sudo cp /tmp/a $ISO/install/filesystem.size
cd $ISO/install
sudo rm -fr filesystem.squashfs.gpg
sudo gpg --armor --detach-sign -o filesystem.squashfs.gpg filesystem.squashfs

# Generate the ISO
cd $OPT
sudo rm -fr test.iso
sudo grub-mkrescue --output=test.iso $ISO/

scp test.iso brenohl@10.1.0.1:/home/brenohl/iso
