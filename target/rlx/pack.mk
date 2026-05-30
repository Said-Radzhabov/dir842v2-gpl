PACK_BLOCK_SIZE  = $(if $(BR2_NAND),128K,64K)

ifeq ($(BR2_NAND),y)
PACK_FLASH_INDEX = $(if $(RTL8685P),0xBFE00000,)
else
PACK_FLASH_INDEX = $(if $(RTL8685P),0xBD040000,0xB4040000)
endif

ifeq ($(RTL8685P)$(RTL8685S)$(RTL8685PB)$(RTL8685FB),y)
ifeq ($(PACK_FLASH_INDEX),)
PACK_GENHEAD = \
	cp $(BINARIES_DIR)/$(LINUX26_IMAGE_NAME) $(BINARIES_DIR)/uImage; \
	cp $(BINARIES_DIR)/rootfs.squashfs $(BINARIES_DIR)/rootfs;
else
PACK_GENHEAD = \
	$(BINARIES_DIR)/genhead  -i $(BINARIES_DIR)/$(FW_IMAGE_NAME) -o $(BINARIES_DIR)/vm.hdr -k 0xa0000003 -f $(PACK_FLASH_INDEX)  -a 0x80000000 -e 0x80000000; \
	cat $(BINARIES_DIR)/vm.hdr $(BINARIES_DIR)/$(FW_IMAGE_NAME) > $(BINARIES_DIR)/vm.img;
endif
endif

pack_image: host-mksign
ifeq ($(BR2_TAR_IMAGE), y)
	cp $(BINARIES_DIR)/rootfs.squashfs $(BINARIES_DIR)/rootfs
	$(PACK_GENHEAD)
	cd $(BINARIES_DIR) && tar -cf img.tar uImage rootfs && rm -f rootfs
	cp $(BINARIES_DIR)/img.tar $(BINARIES_DIR)/$(FW_IMAGE_NAME)
	$(ADD_DATAMODEL_VERSION)
ifneq ($(BR2_PRIVATE_KEY),)
	$(SIGN_DEFAULT_CMD)
endif
	cp -f $(BINARIES_DIR)/$(FW_IMAGE_NAME) $(BINARIES_DIR)/img.tar
else
	dd if=$(BINARIES_DIR)/$(LINUX26_IMAGE_NAME) of=$(BINARIES_DIR)/fw.bin bs=$(PACK_BLOCK_SIZE) conv=sync
	dd if=$(BINARIES_DIR)/rootfs.squashfs of=$(BINARIES_DIR)/fw.bin bs=$(PACK_BLOCK_SIZE) oflag=append conv=notrunc
	mv $(BINARIES_DIR)/fw.bin $(BINARIES_DIR)/$(FW_IMAGE_NAME)
	$(ADD_DATAMODEL_VERSION)
	$(SIGN_DEFAULT_CMD)
	$(PACK_GENHEAD)
endif
