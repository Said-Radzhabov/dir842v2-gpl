#!/bin/sh

logconsole() {
	echo "$@" >/dev/console
	logger "$@"
}

KERNEL="bzImage"
ROOTFS="rootfs.squashfs"
INITRD="initramfs-linux.img"

DEST="/boot/"

logconsole "Start update..."

logconsole "Install kernel"
cp $KERNEL $DEST/$KERNEL.efi

logconsole "Install rootfs"
cp $ROOTFS $DEST/$ROOTFS

logconsole "Install initramfs"
cp $INITRD $DEST/$INITRD

logconsole "DONE"
