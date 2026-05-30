ifeq ($(BR2_PRIVATE_KEY),)
    $(error Pls, set PRIVATE_KEY)
endif

GET_LOAD_START_ADDR_CMD = ""grep CONFIG_LOAD_START_ADDR $(LINUX_CONFIG) | awk -F'=' '{print $$(NF)}'""
GET_FLASH_FW_POS = ""grep CONFIG_FLASH_FW_POS $(LINUX_CONFIG) | awk -F'=' '{print $$(NF)}'""


# добавлять или нет cvimg заголовок (в длинковских прошивках - добавлять, в альфа - поразному)
CVIMG_HEADER_ADD:=y

ifeq ($(BR2_ALPHA_FW),y)
    ifeq ($(PROFILE),$(filter $(PROFILE),DIR_816LB1A_ALPHA DIR_879A1_ALPHA))
        CVIMG_HEADER_ADD:=n
    else
        ifeq ($(PROFILE),$(filter $(PROFILE),DIR_850L_ALPHA DIR_822C1A_ALPHA DIR_809A1A_ALPHA))
            CVIMG_HEADER_ADD:=y
        else
             $(error ALPHA - pls, check fw img format - cvimg header!!!)
        endif
    endif
endif

IMG_TYPE:=linux-ro
ifeq ($(BR2_ALPHA_FW),y)
    IMG_TYPE:=linux
endif


BUILD_TARGETS:=prepare_krn prepare_rootfs union host-cvimg

TMP_KRN=$(BINARIES_DIR)/tmp_krn.bin
TMP_RF=$(BINARIES_DIR)/tmp_rf.bin
TMP_FW=$(BINARIES_DIR)/tmp_fw.bin

ifeq ($(BR2_ALPHA_FW),y)
    BUILD_TARGETS+=host-alpha_utils
endif


#***************************
pack_image: $(BUILD_TARGETS) host-mksign

ifeq ($(CVIMG_HEADER_ADD),y)
#   cvimg заголовок (realtek)
	$(HOST_DIR)/usr/bin/cvimg $(IMG_TYPE) $(TMP_FW) $(BINARIES_DIR)/$(FW_IMAGE_NAME) $(shell $(GET_LOAD_START_ADDR_CMD)) $(shell $(GET_FLASH_FW_POS))
else
#   просто копируем прошивку
	cp $(TMP_FW) $(BINARIES_DIR)/$(FW_IMAGE_NAME)
endif

#   удаление временных файлов
	rm -rf $(TMP_KRN) $(TMP_RF) $(TMP_FW)

ifeq ($(BR2_ALPHA_FW),y)	
#   alpha загловок
	$(HOST_DIR)/usr/bin/alpha_header $(BINARIES_DIR)/$(FW_IMAGE_NAME)

	#шифруем
    ifeq ($(PROFILE),DIR_879A1_ALPHA)
		$(HOST_DIR)/usr/bin/alpha_xor $(BINARIES_DIR)/$(FW_IMAGE_NAME)
    endif

else
	# записываем в образ прошивки версию датамодели
	$(ADD_DATAMODEL_VERSION)

#   dlink подпись
    ifneq ($(ROLLBACK_CUSTOM_LABEL),)
		echo -n $(ROLLBACK_CUSTOM_LABEL) >> $(BINARIES_DIR)/$(FW_IMAGE_NAME)
    else
    ifeq ($(BR2_USE_CUSTOM_LABEL),y)
		echo -n $(BR2_CUSTOM_LABEL) >> $(BINARIES_DIR)/$(FW_IMAGE_NAME)
    endif
    endif

	$(SIGN_DEFAULT_CMD)
endif
#***************************


CVIMG_HEADER_SIZE:=16

#для альфы выравнивай, не выравнивай - бестолку, добавляемый альфа заголовок
#все равно смещает, а он имеет непредсказуемую длину
ifeq ($(BR2_ALPHA_FW),y)
    CVIMG_HEADER_SIZE:=0
endif

prepare_krn:
# стандартное dlink
#   округление ядра, так чтоб следом приклеенная рутфс попала на границу сектора
	cat $(BINARIES_DIR)/$(LINUX26_IMAGE_NAME) > $(TMP_KRN)
	target/rlx/round_file.sh $(TMP_KRN) $(BR2_RLX_KERNEL_PADDING) $(CVIMG_HEADER_SIZE)

prepare_rootfs:
ifeq ($(BR2_ALPHA_FW),y)
#	для альфы
    ifeq ($(PROFILE),$(filter $(PROFILE),DIR_850L_ALPHA DIR_822C1A_ALPHA DIR_816LB1A_ALPHA DIR_879A1_ALPHA))
		target/rlx/alpha_prepare_rootfs.sh $(BINARIES_DIR)/rootfs.squashfs $(TMP_RF)
    else
        ifeq ($(PROFILE),$(filter $(PROFILE),DIR_809A1A_ALPHA))
			cat $(BINARIES_DIR)/rootfs.squashfs >>  $(TMP_RF)
        else
            $(error ALPHA - pls, check rootfs img format!!!)
        endif
    endif
else
#	стандартное dlink
	cat $(BINARIES_DIR)/rootfs.squashfs >>  $(TMP_RF)
endif	

union:
#	объединение ядра и рутфс
	cat $(TMP_KRN) > $(TMP_FW)
	cat $(TMP_RF) >> $(TMP_FW)

define GET_FW_OFFSET
	$(shell $(GET_FLASH_FW_POS))
endef
