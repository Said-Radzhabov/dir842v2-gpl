

#USE_INITRD=$(shell grep -w CONFIG_BLK_DEV_INITRD $(LINUX_CONFIG) | sed -r 's/CONFIG_BLK_DEV_INITRD=//1')
USE_INITRD=$(shell grep -c "CONFIG_BLK_DEV_INITRD=y" $(LINUX_CONFIG))

rtk_ms_check_initrd:
	@if [ $(call USE_INITRD) != 0 ]; then			\
		$(call MESSAGE,rootfs-cpio + kernel initrd);	\
		rm -f $(LINUX26_DIR)/.stamp_compiled;		\
		$(MAKE) rtk_ms_rebuild_kernel;			\
	fi && true || false

rtk_ms_rebuild_kernel: rootfs-cpio
	@$(MAKE) kernel-build CONFIG_INITRAMFS_SOURCE="../../images/rootfs.cpio"
	@$(call MESSAGE,"Re-installing kernel")
	cp -f $(LINUX26_IMAGE_PATH) $(BINARIES_DIR)



rtk_ms_uimage: host-rtk_ms_mkimage host-lzma
	$(LZMA) e $(BINARIES_DIR)/$(LINUX26_IMAGE_NAME) $(BINARIES_DIR)/$(LINUX26_IMAGE_NAME).lzma 2>&1
	$(HOST_DIR)/usr/bin/mkimage -A mips -O linux -T kernel -C lzma -a 0x${LDADDR} -e ${ENTRY} -n ${DEVICE_ID}    \
	-d $(BINARIES_DIR)/$(LINUX26_IMAGE_NAME).lzma $(BINARIES_DIR)/uImage

pack_image: rtk_ms_check_initrd | rtk_ms_uimage
	@if [ $(call USE_INITRD) != 0 ]; then					\
		cp $(BINARIES_DIR)/uImage $(BINARIES_DIR)/$(FW_IMAGE_NAME);	\
	else									\
		$(MAKE) _append_rootfs NODEP=y;					\
	fi && true || false
	@$(call MESSAGE,"RTK MSwitch: $(FW_IMAGE_NAME) is ready")

# 64k - hardcoded, see rtk_norsf_g3.c
# must be equal
# but the flash supports 4k block.
FW_BLOCK_SIZE := 64
ifneq ($(BR2_PRIVATE_KEY),)
_append_rootfs: host-mksign
endif
_append_rootfs:
	@if [ "$(NODEP)" != "y" ]; then			\
		echo "do not call $@ directly";		\
		false;					\
	fi && true || false
	dd if=$(BINARIES_DIR)/uImage of=$(BINARIES_DIR)/$(FW_IMAGE_NAME) bs=$(FW_BLOCK_SIZE)k conv=sync 2>&1
	dd if=$(BINARIES_DIR)/rootfs.squashfs of=$(BINARIES_DIR)/$(FW_IMAGE_NAME) oflag=append conv=notrunc 2>&1
ifneq ($(BR2_PRIVATE_KEY),)
	$(ADD_DATAMODEL_VERSION)
	$(SIGN_DEFAULT_CMD)
endif



# Взято из pack.mk.qca
rtk_ms_bfs = $(PROFILE_DIR)/buildFS
# забросим профильный скелетон в target
$(TARGET_DIR): $(BUILD_DIR)/.profile_skeleton
# причём после основного скелетона
$(BUILD_DIR)/.profile_skeleton: $(BUILD_DIR)/.root
	@echo "running $(rtk_ms_bfs) ..."
	@if [ -x $(rtk_ms_bfs) ]; then				\
		$(rtk_ms_bfs) $(PROFILE_DIR) $(TARGET_DIR);	\
	else							\
		echo "$(rtk_ms_bfs) not found";			\
	fi && true || false
	@touch $@
