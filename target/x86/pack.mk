# Для X86 архитектуры пока не очень понятно, как вообще должна выглядеть
# "прошивка" и как будет выглядеть процесс обновления
#
# Системе потребуются следующие файлы:
# * bzImage.efi         - ядро
# * initramfs-linux.img - initrd
# * rootfs.squashfs     - rootfs
#
# Дополнительно нужно положить загрузчик systemd-boot и его конфиги, на случай
# обновления или восстановления.
#
# И понадобится проинсталлировать скрипт startup.nsh - чтобы загружался наш
# загрузчик. Это понадобится в случае накатывания нашей системы поверх другой.

PACK_ARCHIVE_FILE_LIST = \
	$(LINUX26_IMAGE_NAME) \
	initramfs-linux.img   \
	install

PACK_SIGN_IMAGE   =
PACK_CUSTOM_LABEL =

ifneq ($(BR2_PRIVATE_KEY),)
PACK_SIGN_IMAGE   = $(SIGN_DEFAULT_CMD)
endif

ifneq ($(ROLLBACK_CUSTOM_LABEL),)
PACK_CUSTOM_LABEL = echo -n $(ROLLBACK_CUSTOM_LABEL) >> $(BINARIES_DIR)/$(FW_IMAGE_NAME)
else
ifeq ($(BR2_USE_CUSTOM_LABEL),y)
PACK_CUSTOM_LABEL = echo -n $(BR2_CUSTOM_LABEL) >> $(BINARIES_DIR)/$(FW_IMAGE_NAME)
endif
endif

ifeq ($(BR2_FW_INITRAMFS_IMAGE),)
BR2_FW_INITRAMFS_IMAGE = $(TOPDIR)/target/x86/initramfs-linux.img
endif

ifeq ($(BR2_FW_INSTALL_SCRIPT),)
BR2_FW_INSTALL_SCRIPT = $(TOPDIR)/target/x86/install.sh
endif

ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS),y)
PACK_ARCHIVE_FILE_LIST += rootfs.squashfs
endif

$(BINARIES_DIR)/initramfs-linux.img:
	cp $(BR2_FW_INITRAMFS_IMAGE) $@

$(BINARIES_DIR)/install:
	cp $(BR2_FW_INSTALL_SCRIPT) $@

pack_image: $(BINARIES_DIR)/install $(BINARIES_DIR)/initramfs-linux.img host-mksign
	tar -cf $(BINARIES_DIR)/fw.tar -C $(BINARIES_DIR) $(PACK_ARCHIVE_FILE_LIST)
	cp $(BINARIES_DIR)/fw.tar  $(BINARIES_DIR)/$(FW_IMAGE_NAME)

	$(ADD_DATAMODEL_VERSION)
	$(PACK_CUSTOM_LABEL)
	$(PACK_SIGN_IMAGE)
