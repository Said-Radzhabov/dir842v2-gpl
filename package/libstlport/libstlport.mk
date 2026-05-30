################################################################################
#
# libstlport
#
################################################################################

LIBSTLPORT_SITE = $(DLINK_STORAGE)
LIBSTLPORT_VERSION = 5.2.1
LIBSTLPORT_LICENSE = AFLv3
LIBSTLPORT_CFLAGS = $(TARGET_CFLAGS)
LIBSTLPORT_CXXFLAGS = $(TARGET_CXXFLAGS)

LIBSTLPORT_INSTALL_STAGING = NO
LIBSTLPORT_INSTALL_TARGET = YES

TOOL_PATH=$(TOOLCHAIN_DIR)/bin

define LIBSTLPORT_CONFIGURE_CMDS
	cd $(@D); \
	./configure --use-compiler-family=gcc \
			--target=$(BR2_TOOLCHAIN_EXTERNAL_PREFIX) \
			--prefix=$(TARGET_DIR)/usr \
			--includedir=$(STAGING_DIR)/usr/include \
			--with-extra-cxxflags="$(LIBSTLPORT_CXXFLAGS)" \
			--with-extra-cflags="$(LIBSTLPORT_CFLAGS)"
endef

define LIBSTLPORT_BUILD_CMDS
	cd $(@D)/build/lib; \
	export PATH=$(BR_PATH):$(TOOL_PATH); \
	$(MAKE) -f gcc.mak install-release-shared
endef

define LIBSTLPORT_INSTALL_TARGET_CMDS
	export PATH=$(BR_PATH):$(TOOL_PATH); \
	$(MAKE) -C $(@D) INSTALL_PREFIX=$(TARGET_DIR) install
	$(INSTALL) -D -m 0755 $(TARGET_DIR)/usr/$(BR2_TOOLCHAIN_EXTERNAL_PREFIX)-lib/* $(TARGET_DIR)/usr/lib/
	rm -rf $(TARGET_DIR)/usr/$(BR2_TOOLCHAIN_EXTERNAL_PREFIX)-lib/
endef

define LIBSTLPORT_INSTALL_STAGING_CMDS
	export PATH=$(BR_PATH):$(TOOL_PATH); \
	$(MAKE) -C $(@D) INSTALL_PREFIX=$(STAGING_DIR) install-headers
endef

define LIBSTLPORT_CLEAN_CMDS
	export PATH=$(BR_PATH):$(TOOL_PATH); \
	$(MAKE) -C $(@D) clean
endef

define LIBSTLPORT_UNINSTALL_TARGET_CMDS
	rm -rf $(TARGET_DIR)/usr/$(BR2_TOOLCHAIN_EXTERNAL_PREFIX)-lib/
	rm -rf $(TARGET_DIR)/usr/lib/libstlport*
endef

define LIBSTLPORT_UNINSTALL_STAGING_CMDS
	rm -rf $(STAGING_DIR)/usr/include/stlport/
endef

$(eval $(call GENTARGETS))
