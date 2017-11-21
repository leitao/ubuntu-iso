Script to create Ubuntu ISO
===========================

Purpose: 
-------

Script to create an ISO IMAGE in Ubuntu with a newer custom kernel.

Requirements:
------------
 * 'pristine' Ubuntu image
 * New Kernel
 * New DI (recompiled against the new kernel)
 * New Keyring (with your public key)

Parameters:
----------

Run this script and set the $OPT to the current directory. All the other files need to be under this directory. I use this script inside $OPT (which in my case is /opt) where I have the old ISO image at $OLDISO.

I also have a new KEYRING package built at $KEYRING. You will need to regenerated the keyring package with you pub key as explained at https://help.ubuntu.com/community/InstallCDCustomization#Generating_a_new_ubuntu-keyring_.deb_to_sign_your_CD

The new debian installer (DI) should be recompiled with the new kernel and should be at $DI.

The new custom kernel packages should be a $KERNEL.


References:
----------
 * https://help.ubuntu.com/community/InstallCDCustomization
 * https://help.ubuntu.com/community/InstallCDCustomization#Generate_a_new_filesystem.squashfs_with_the_updated_ubuntu-archive-keyring.gpg
 * https://help.ubuntu.com/community/InstallCDCustomization#Building_the_repository_with_apt-ftparchive
 * https://help.ubuntu.com/community/InstallCDCustomization#Generating_a_new_ubuntu-keyring_.deb_to_sign_your_CD
 * https://help.ubuntu.com/community/InstallCDCustomization

Thanks:
-------

I would like to thanks Frederic Bonnard for creating a tutorial that this scripts is based on.
