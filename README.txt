============================== Introduction
This file shows how to build the DIR-842 Firmware

============================== Environment 
Sample workstation to build the image
	OS Version: 		Debian 9.13 (32-bit version)
	OS Kernel Version:	4.9.0-12-686
	GCC Version:		6.3.0 (Debian 6.3.0-18+deb9u1)
	note: other Linux distributions may have no guarantee of a successful build	
	
Setup Environment:
	1. Make sure you can connect to the Internet.
	2. Download debian-9.13.0-i386-netinst.iso from https://cdimage.debian.org/cdimage/archive/9.13.0/i386/iso-cd/debian-9.13.0-i386-netinst.iso
	3. Install Debian 9.13 with all packages
	4. Install additional packages:
		a) #su (enter your root password to become root)
		b) #apt update
		c) #apt install -y wget git gcc g++ make autoconf automake autopoint gettext libtool pkg-config bison flex bc python gawk procps zlib1g-dev
		d) #exit (you don't need a root access anymore)
	5. Prepare a directory to build the DIR-842 firmware:
		a) #cd ~/ (go to your home directory)
		b) Copy gpl_DIR_842F_RT8197G_WW_DEUR.zip to your home directory
		c) #unzip gpl_DIR_842F_RT8197G_WW_DEUR.zip
		Now you have two new files in your home directory: gpl_DIR_842F_RT8197G_WW_DEUR.tar.gz and MD5.txt
		d) #md5sum gpl_DIR_842F_RT8197G_WW_DEUR.tar.gz (to calculate checksum)
		Compare a calculated checksum with checksum from file MD5.txt. They must be the same.
		e) #tar xvf gpl_DIR_842F_RT8197G_WW_DEUR.tar.gz
		Now you have a directory gpl_DIR_842F_RT8197G_WW_DEUR in your home directory.

============================== Firmware 	
Build Firmware:
	Please follow the procedures below:
	1. #cd ~/gpl_DIR_842F_RT8197G_WW_DEUR
	2. #make
	You will get the image file: XXXXYYZZ_HHMM_DIR_842F_RT8197G_WW_DEUR_develop_sdk-master.bin in ~/gpl_DIR_842F_RT8197G_WW_DEUR/output/images
	Where XXXXYYZZ and HHMM - curren date and time.
   	3. Congratulations! You got your specific image now.
