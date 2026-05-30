#############################################################
#
# Build the squashfs root filesystem image
#
#############################################################

ROOTFS_SQUASHFS_DEPENDENCIES = host-squashfs

# аргументы

ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS),y)
ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS_BS),)
$(error BR2_TARGET_ROOTFS_SQUASHFS_BS is not set)
endif
endif

ROOTFS_SQUASHFS_ARGS += -all-root -noappend
ROOTFS_SQUASHFS_ARGS += -b $(BR2_TARGET_ROOTFS_SQUASHFS_BS)

ifneq ($(BR2_DUAL_BOOT_FW),y)
# для дуалбута (#10761) нельзя делать -nopad
#. т.к. обновлятель из загрузчика ищет 0x00coffee
# с шагом 4 байта. Так что для дуалбута оставим
# дополнение до 4K.
# Нет дуалбута => не надо padding'а
ROOTFS_SQUASHFS_ARGS += -nopad
endif

ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS4_LZO),y)
	ROOTFS_SQUASHFS_ARGS += -comp lzo
else ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS4_LZMA),y)
	ROOTFS_SQUASHFS_ARGS += -comp lzma
else ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS4_XZ),y)
	ROOTFS_SQUASHFS_ARGS += -comp xz
else
	ROOTFS_SQUASHFS_ARGS += -comp gzip
endif

ROOTFS_SQUASHFS_EXE = $(HOST_DIR)/usr/bin/mksquashfs

define ROOTFS_SQUASHFS_CMD
	$(ROOTFS_SQUASHFS_EXE) $(TARGET_DIR) $$@ $(ROOTFS_SQUASHFS_ARGS) && \
	chmod 0644 $$@
endef

$(eval $(call ROOTFS_TARGET,squashfs))
