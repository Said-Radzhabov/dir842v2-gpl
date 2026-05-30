# инклудится при BR2_DRU_BOOTSTRAP

ifeq ($(call qstrip,$(DLINK_DEVICEID)),DAP_1620A1_MT7620A)
# $ hexdump -C DAP-1620.ORIGINAL.FULL.img | grep 150116
# 0001d3c0  52 50 2d 31 35 30 31 31  36 2d 4e 41 00 00 00 00  |RP-150116-NA....|
# 0001eac0  52 50 2d 31 35 30 31 31  36 2d 4e 41 5c d1 01 bc  |RP-150116-NA\...|
# 004dfff0  30 2d 52 50 2d 31 35 30  31 31 36 2d 4e 41 5d 81  |0-RP-150116-NA].|
# 007ffff0  30 2d 52 50 2d 31 35 30  31 31 36 2d 42 4b ff ff  |0-RP-150116-BK..|

# Всё оказалось, сложнее:
# Китайцы юзают дуалбут, у них прошивки много компактнее
# И позиция рутфс1 строгая, они не юзают склеивание как мы.
# Так что настоящая транзитная прошива должна быть
#  1. С кастомным профилем - надо много порезать,
#     чтоб корневая влезла в их mtd5 :
#     0x000000140000-0x0000004e0000 : "rootfs" => 3712K
#  2. С кастомным конфигом ядра, чтоб поместиться в mtd4:
#     0x000000050000-0x000000140000 : "linux4" => 960K
# Т.е. надо ещё галку в профиле типа "bool Transit",
# всю логику кастомных профилей/конфигов на это дело,
# сообщение в морду, что это транзитная штука с порезанным
# функционалом и всё такое.
# А тут ещё оказалось, что производиться они будут с завода,
# т.е. никакиз транзитов, всё из коробки.
# Так что нах не надо.
# Потому отключу сигнатуру (автоматом вырубается соотв. код в
# либшареде, где даунгрейд и AR_SIGNATURE_CONTINUE, ls:13dc7ad)
# Не забыть потом снести -DBOOTSTRAP в ls/Makefile для этого профиля.
# Кстати, правильная сигнатура: -BK, хотя -NA упоминается в оригинальном
# имидже (см. hexdump выше)
# UPDATE: хрен! Вот при зашивании через штатную морду надо NA

SIGNATURE := MT76XMT7620-RP-150116-NA
#SIGNATURE := MT76XMT7620-RP-150116-BK
#SIGNATURE :=
else
$(error bootstrap is not supported for $(PROFILE) of device $(DLINK_DEVICEID))
endif

ifneq ($(SIGNATURE),)
LIBSHARED_CFLAGS += -DAR_SIGNATURE='\""$(SIGNATURE)"\"'
LIBSHARED_CFLAGS += -DAR_SIGNATURE_CONTINUE
endif

UIMAGE_MAXSIZE = 983040
ROOTFS_MAXSIZE = 3801088
# TODO 1: уменьшать выхлоп выравнивания с учётом до 2-х подписей.
# Но пока v1.00 и так жрёт.
# TODO 2: при повторном make дополненные имиджи уже будут слишком большими
# автоматом вылезет после фикса первого TODO 1.

filesize=$(shell stat -L -c %s $(1))
toobig=$(shell test $(call filesize,$(1)) -le $(2) -a $(call filesize,$(3)) -le $(4) && echo n || echo y)

TMP_IMAGE = $(BINARIES_DIR)/tmp.image

pack_image:
	@if [ $(call toobig, $(BINARIES_DIR)/uImage,$(UIMAGE_MAXSIZE), $(BINARIES_DIR)/rootfs.squashfs,$(ROOTFS_MAXSIZE)) = y ]; then \
	  echo '================================'; \
	  echo '============ ERROR ============='; \
	  echo sizes of the kernel and rootfs are; \
	  echo too big to make transit image:; \
	  echo kernel: $(call filesize,$(BINARIES_DIR)/uImage) bytes; \
	  echo rootfs: $(call filesize,$(BINARIES_DIR)/rootfs.squashfs) bytes; \
	  echo limits: 960K and 3712K; \
	  echo '================================'; \
	  false; \
	fi
	@echo "kernel ..."
	dd if=/dev/zero of=$(TMP_IMAGE) bs=960K count=1
	dd if=$(BINARIES_DIR)/uImage of=$(TMP_IMAGE) conv=notrunc
	mv $(TMP_IMAGE) $(BINARIES_DIR)/uImage
	@echo "rootfs ..."
	dd if=/dev/zero of=$(TMP_IMAGE) bs=3712K count=1
	dd if=$(BINARIES_DIR)/rootfs.squashfs of=$(TMP_IMAGE) conv=notrunc
	mv $(TMP_IMAGE) $(BINARIES_DIR)/rootfs.squashfs
