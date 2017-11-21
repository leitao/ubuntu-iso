Script to create Ubuntu ISO
===========================

Purpose: 
-------

Script to create an ISO IMAGE in Ubuntu with a newer custom kernel.

Parameters:
----------

I use This script inside $OPT (which in my case is /opt) where I have the old ISO image at $OLDISO.
I also have a new KEYRING package built at $KEYRING. You will need to regenerated the keyring package with you pub key as explained at https://help.ubuntu.com/community/InstallCDCustomization#Generating_a_new_ubuntu-keyring_.deb_to_sign_your_CD

The new debian installer (DI) should be recompiled with the new kernel and should be at $DI.

The new custom kernel packages should be a $KERNEL.

