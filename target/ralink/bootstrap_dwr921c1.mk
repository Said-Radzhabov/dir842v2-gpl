# инклудится при BR2_DRU_BOOTSTRAP
# только при DLINK_DEVICEID = DWR_921 (UPDATE: или DWR_953A1)


ifeq ($(call qstrip,$(BR2_BOOTLOADER_INSTALL_FILE)),)
$(error $(DLINK_DEVICEID) needs uboot for transit)
endif

ifeq ($(call qstrip,$(BR2_DRU_BOOTSTRAP_STAGE2_IMAGE)),)
$(error $(DLINK_DEVICEID) needs stage2 firmware for transit)
endif

#ifneq (${BR2_BOOTLOADER_UPDATE_FROM_FW},y)
#$(error $(DLINK_DEVICEID) needs uboot for transit)
#endif

# флешка: W25Q128FV
# разбиение:
# мы:
# dev:    size   erasesize  name
# mtd0: 01000000 00010000 "ALL"
# mtd1: 00030000 00010000 "Bootloader"
# mtd2: 00010000 00010000 "Config"
# mtd3: 00010000 00010000 "Factory"
# mtd4: 00130000 00010000 "Kernel"
# mtd5: 00e80000 00010000 "RootFS"
# mtd6: 00fb0000 00010000 "Linux"
#
# они:
# cat /proc/mtd
# dev:    size   erasesize  name
# mtd0: 01000000 00001000 "Whole"
# mtd1: 00010000 00001000 "Bootloader"
# mtd2: 00140000 00001000 "Kernel"
# mtd3: 00d90000 00001000 "RootFS"
# mtd4: 000dfff0 00001000 "UI"
# mtd5: 00010000 00001000 "Config"
#
# Creating 6 MTD partitions on "raspi":
# 0x000000000000-0x000001000000 : "Whole"
# 0x000000000000-0x000000010000 : "Bootloader"
# 0x000000010000-0x000000150000 : "Kernel"
# 0x000000180000-0x000000f10000 : "RootFS"
# 0x000000f10010-0x000000ff0000 : "UI"
# mtd: partition "UI" doesn't start on an erase block boundary -- force read-only
# 0x000000ff0000-0x000001000000 : "Config"





# добавочная зависимость для финализации из корневого макефайла
target-pre-finalize: dwr921c1_add_content

dwr921c1_add_content: $(TARGET_DIR)/bin/bootstrap
# убут есть в финализации, но как необязательная вещь (с минусом)
# продублируем, как необходимую:
	cp -f $(PROFILE_DIR)/$(BR2_BOOTLOADER_INSTALL_FILE) $(TARGET_DIR)/bin/uboot.img
	cp -f $(BR2_DRU_BOOTSTRAP_STAGE2_IMAGE) $(TARGET_DIR)/bin/firmware.bin
	ln -snf ../bin/bootstrap $(TARGET_DIR)/sbin/init

$(TARGET_DIR)/bin/bootstrap: $(PROFILE_DIR)/bootstrap.c
	$(TARGET_CC) -Wall -Werror $^ -o $@

# предельные размеры транзита, чтоб попасть в китайское разбиение
#1280K = 1,25M
KERNEL_MAXSIZE = 1310720
#13888K ~= 13.5M
ROOTFS_MAXSIZE = 14221312

filesize=$(shell stat -L -c %s $(1))
toobig=$(shell test $(call filesize,$(1)) -le $(2) -a $(call filesize,$(3)) -le $(4) && echo n || echo y)

# пусть всё соберётся к этому времени: uimage
# сделаем firmware.bin нужного формата
#
# цель сделана отдельно, чтоб filesize и toobig
# вызывались в другой цели. Потому что функции цели
# выполняются между пререквизитами и рецептом,
# когда файлы ещё могут не существовать.
# Поэтому создадим их тут, а к размерам будем
# обращаться в pack_image.
# См. журнал пидгина с eegorov и mzhukov
# от 2016.06.28
# Такой порядок выполнения функций используется
# и в make 3.81, и в 4.1.

bootstrap_bins:
	cd $(BINARIES_DIR); cp vmlinux.bin.lzma zImage.lzma
	cd $(BINARIES_DIR); cp rootfs.squashfs squashfs.o
	cd $(BINARIES_DIR); $(PROFILE_DIR)/binboy @linux
	cd $(BINARIES_DIR); $(PROFILE_DIR)/binboy @rootfs
	cd $(BINARIES_DIR); $(PROFILE_DIR)/binboy @all

# определим pack_image, тут он свой,
# а не в ../pack.mk, как у прочих
pack_image: bootstrap_bins
	@if [ $(call toobig, $(BINARIES_DIR)/kernel.bin,$(KERNEL_MAXSIZE), $(BINARIES_DIR)/rootfs.bin,$(ROOTFS_MAXSIZE)) = y ]; then \
	  echo '================================'; \
	  echo '============ ERROR ============='; \
	  echo sizes of the kernel and rootfs are; \
	  echo too big to make transit image:; \
	  echo kernel: $(call filesize,$(BINARIES_DIR)/kernel.bin) bytes; \
	  echo rootfs: $(call filesize,$(BINARIES_DIR)/rootfs.bin) bytes; \
	  echo limits: 1280K and 13888K; \
	  echo '================================'; \
	  false; \
	fi
	mv $(BINARIES_DIR)/firmware.bin $(BINARIES_DIR)/$(FW_IMAGE_NAME)
