FW_BLOCK_SIZE = $(call qstrip,$(BR2_NAND_BLOCK_SIZE))

ifeq ($(FW_BLOCK_SIZE),)
FW_BLOCK_SIZE := 128
endif

ifeq ($(FW_BLOCK_SIZE),128)
PAGE_SIZE := 2048
else
PAGE_SIZE := 4096 #для флешек блоком 256 и 512 страничный размер один и тот же
endif

BYTES:=$(shell echo $(FW_BLOCK_SIZE)\*1024 | bc)
LEB := $(shell echo $(BYTES)\-2\*$(PAGE_SIZE) | bc)
pack_image: host-uboot-tools host-mksign host-lzma host-bcm_hottools host-mtd
	@echo -e "\033[1mPack call....\033[0m"
	@rm  $(LINUX26_DIR)/.stamp_installed

	cp $(LINUX26_DIR)/vmlinux $(BINARIES_DIR)/.

	$(TARGET_STRIP) --remove-section=.note --remove-section=.comment $(BINARIES_DIR)/vmlinux
	@echo "Let me see you stripped"
	$(TARGET_OBJCOPY) -O binary $(BINARIES_DIR)/vmlinux $(BINARIES_DIR)/vmlinux.bin
	$(BCM_CMPLZMA) -k -2 -lzma $(BINARIES_DIR)/vmlinux $(BINARIES_DIR)/vmlinux.bin $(BINARIES_DIR)/vmlinux.lz
	mkdir -p $(BINARIES_DIR)/bootfs

	cp $(PROFILE_DIR)/cfe63178ram.bin $(BINARIES_DIR)/bootfs/cferam.000
	cp $(LINUX26_DIR)/arch/arm/boot/bcmdts/dts/63178/963178.dtb $(BINARIES_DIR)/bootfs/
	cp $(LINUX26_DIR)/arch/arm/boot/bcmdts/dts/63178/963178REF1.dtb $(BINARIES_DIR)/bootfs/
	echo -e "/cferam.000" > $(BINARIES_DIR)/nocomprlist
	echo -e "/963178.dtb" >> $(BINARIES_DIR)/nocomprlist
	echo -e "/963178REF1.dtb" >> $(BINARIES_DIR)/nocomprlist
	echo -e "/vmlinux.lz" >> $(BINARIES_DIR)/nocomprlist
	cp $(BINARIES_DIR)/vmlinux.lz $(BINARIES_DIR)/bootfs
	$(BCM_JFFS2) --squash-uids -l -p -n -e $(BYTES) -r $(BINARIES_DIR)/bootfs -o $(BINARIES_DIR)/ibootfs$(FW_BLOCK_SIZE)kb.img -N $(BINARIES_DIR)/nocomprlist
	$(SUMTOOL) -l -p -i $(BINARIES_DIR)/ibootfs$(FW_BLOCK_SIZE)kb.img -o $(BINARIES_DIR)/bootfs$(FW_BLOCK_SIZE)kb.img -e $(FW_BLOCK_SIZE)KiB -n
	rm -f $(BINARIES_DIR)/ibootfs$(FW_BLOCK_SIZE)kb.img
	echo -e "[ubifs]" > $(BINARIES_DIR)/ubi.ini
	echo -e "mode=ubi">> $(BINARIES_DIR)/ubi.ini
	echo -e "image=$(BINARIES_DIR)/rootfs_$(FW_BLOCK_SIZE).ubifs" >> $(BINARIES_DIR)/ubi.ini
	echo -e "vol_id=0"               >> $(BINARIES_DIR)/ubi.ini
	echo -e "vol_type=dynamic" >> $(BINARIES_DIR)/ubi.ini
	echo -e "vol_name=rootfs_ubifs"  >> $(BINARIES_DIR)/ubi.ini
	echo -e "vol_flags=autoresize"   >> $(BINARIES_DIR)/ubi.ini

	$(MKFS_UBI) --squash-uids -F -v -c 2048 -m $(PAGE_SIZE) -e $(LEB) -x zlib -r $(TARGET_DIR) -o $(BINARIES_DIR)/rootfs_$(FW_BLOCK_SIZE).ubifs
	$(UBINIZE) -v -o $(BINARIES_DIR)/ubi_rootfs_$(FW_BLOCK_SIZE).img -m $(PAGE_SIZE) -p $(BYTES)  $(BINARIES_DIR)/ubi.ini

	$(MKFS_UBI) --squash-uids -F -v -c 2048 -m $(PAGE_SIZE) -e $(LEB) -x zlib -r $(TARGET_DIR) -o $(BINARIES_DIR)/rootfs.ubifs

	env BINARIES_DIR=$(BINARIES_DIR) $(HOST_DIR)/usr/bin/scripts/buildUBI -u $(BINARIES_DIR)/ubi_full.ini -m $(BINARIES_DIR)/metadata.bin -f $(BINARIES_DIR)/filestruct_full.bin -t $(BINARIES_DIR)/bootfs -y $(BINARIES_DIR)/rootfs.ubifs
	$(UBINIZE) -v -o $(BINARIES_DIR)/ubi_rootfs$(FW_BLOCK_SIZE)kb_pureubi.img -m $(PAGE_SIZE) -p $(BYTES) $(BINARIES_DIR)/ubi_full.ini

	BINARIES_DIR=$(BINARIES_DIR) HOSTTOOLS_DIR=$(HOST_DIR)/usr/bin/ BRCM_VOICE_BOARD_ID="" BRCM_NUM_MAC_ADDRESSES=11 BRCM_BOARD_ID=BCM963178DVT SECURE_BOOT_ARCH=GEN3 BRCM_CHIP=63178 \
	ARCH_ENDIAN=little BTRM_BOOT_ONLY=y BTRM_IMAGE_SIZE_ALLOCATION=128 BTRM_NAND_BOOT_PARTITION_SIZE=1024 \
	BRCM_BASE_MAC_ADDRESS="02:10:18:01:00:01" BRCM_MAIN_TP_NUM=0  BRCM_PSI_SIZE=48  BRCM_AUXFS_PERCENT="" BRCM_GPON_SERIAL_NUMBER="" BRCM_GPON_PASSWORD="" \
	BRCM_MISC1_PARTITION_SIZE=8 BRCM_MISC2_PARTITION_SIZE=0 BRCM_MISC3_PARTITION_SIZE=0 BRCM_MISC4_PARTITION_SIZE=8 BTRM_NUM_IMAGES_IN_PARTITION=6 $(HOST_DIR)/usr/bin/scripts/bcmImageMaker --cferom $(PROFILE_DIR)/cfe63178rom.bin --blocksize $(BYTES) --bootofs 65536 --bootsize $(BYTES)  --rootfs ubi_rootfs$(FW_BLOCK_SIZE)kb_pureubi.img --image bcm963178GW_nand_cferom_fs_image_$(FW_BLOCK_SIZE)_pureubi --fsonly ${FW_IMAGE_NAME} --ubionlyimage  --unsecurehdr
	mv $(BINARIES_DIR)/${FW_IMAGE_NAME}.w $(BINARIES_DIR)/${FW_IMAGE_NAME}

	$(ADD_DATAMODEL_VERSION)
	$(SIGN_DEFAULT_CMD)

	@$(call MESSAGE,"Packing done")


define GET_FW_OFFSET
	0x00
endef
