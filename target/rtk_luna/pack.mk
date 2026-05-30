define GET_FW_OFFSET
      0x100000
endef

pack_image: host-mksign
	cp $(BINARIES_DIR)/rootfs.squashfs $(BINARIES_DIR)/rootfs
	cd $(BINARIES_DIR) && tar -cf img.tar uImage rootfs && rm -f rootfs
	cp $(BINARIES_DIR)/img.tar $(BINARIES_DIR)/$(FW_IMAGE_NAME)
	$(ADD_DATAMODEL_VERSION)
ifneq ($(BR2_PRIVATE_KEY),)
	$(SIGN_DEFAULT_CMD)
endif
	cp -f $(BINARIES_DIR)/$(FW_IMAGE_NAME) $(BINARIES_DIR)/img.tar
