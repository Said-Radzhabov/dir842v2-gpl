#############################################################
#
# rtw6_driver
#
#############################################################

RTW6_DRIVER_VERSION=$(call qstrip,$(BR2_PACKAGE_RTW6_DRIVER_VERSION))
RTW6_DRIVER_SITE = $(DLINK_GIT_STORAGE)/rtl_wifi
RTW6_DRIVER_LICENSE = GPL-2.0-only
RTW6_DRIVER_INSTALL_STAGING = YES
RTW6_DRIVER_DEPENDENCIES = kernel
RTW6_DRIVER_PROFILE=$(call qstrip, $(BR2_PACKAGE_RTW6_DRIVER_PROFILE))
RTW6_DRIVER_CONF_PATH=$(call qstrip, $(BR2_PACKAGE_RTW6_CONFIG_PATH))

RTW6_DRIVER_MAKE_OPTS = \
	ARCH=$(KERNEL_ARCH) \
	CROSS_COMPILE=$(TARGET_CROSS)

define RTW6_DRIVER_CONFIGURE_CMDS
	cp -f $(@D)/dlink_profiles/config_$(RTW6_DRIVER_PROFILE) $(@D)/.config
	$(MAKE) $(RTW6_DRIVER_MAKE_OPTS) -C $(RTW6_DRIVER_DIR) rtl8192fe_configure
endef

define RTW6_DRIVER_BUILD_CMDS
	$(MAKE) V=99 $(RTW6_DRIVER_MAKE_OPTS) -C $(@D)
endef

define RTW6_DRIVER_INSTALL_STAGING_CMDS
	cp -f $(@D)/backport-include/backport/autoconf.h $(BR2_AUTOHEADER_DIR)/rtw6_autoconf.h
endef

define RTW6_DRIVER_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)$(RTW6_DRIVER_CONF_PATH)
	cp -rf $(@D)/drivers/net/wireless/realtek/g6_wifi_driver/platform/mips_98d/rtl8852ae $(TARGET_DIR)$(RTW6_DRIVER_CONF_PATH)
	$(INSTALL) -d $(LINUX_MODULE_DIR)
	find $(@D) -name "*.ko" -exec $(INSTALL) -m 0644 {} $(LINUX_MODULE_DIR) \;
endef

define RTW6_DRIVER_CLEAN_CMDS
	$(MAKE) $(RTW6_DRIVER_MAKE_OPTS) -C $(@D) clean
endef

rtw6_driver-menuconfig:
	$(MAKE) $(RTW6_DRIVER_MAKE_OPTS) -C $(RTW6_DRIVER_DIR) menuconfig
	$(MAKE) $(RTW6_DRIVER_MAKE_OPTS) -C $(RTW6_DRIVER_DIR) rtl8192fe_configure

$(eval $(call GENTARGETS))
