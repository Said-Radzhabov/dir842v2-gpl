################################################################################
#
# luafilesystem
#
################################################################################

LUAFILESYSTEM_VERSION = v1_8_0
LUAFILESYSTEM_SOURCE = luafilesystem-$(LUAFILESYSTEM_VERSION).tar.gz
LUAFILESYSTEM_SITE = $(DLINK_STORAGE)
LUAFILESYSTEM_LICENSE = MIT
LUAFILESYSTEM_LICENSE_FILES = LICENSE

LUAFILESYSTEM_INSTALL_PATH = "/usr/lib/lua/$(BR2_PACKAGE_LUAINTERPRETER_ABI_VERSION)/lfs.so"

define LUAFILESYSTEM_BUILD_CMDS
	$(MAKE) PREFIX=$(HOST_DIR)/usr -C $(@D) lib
endef

define LUAFILESYSTEM_INSTALL_STAGING_CMDS
	$(INSTALL) -m 0644 -D $(@D)/src/lfs.so $(STAGING_DIR)$(LUAFILESYSTEM_INSTALL_PATH)
endef

define LUAFILESYSTEM_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0644 -D $(@D)/src/lfs.so $(TARGET_DIR)$(LUAFILESYSTEM_INSTALL_PATH)
endef

define HOST_LUAFILESYSTEM_BUILD_CMDS
	$(MAKE) PREFIX=$(HOST_DIR)/usr -C $(@D) lib
endef

define HOST_LUAFILESYSTEM_INSTALL_CMDS
	$(INSTALL) -m 0644 -D $(@D)/src/lfs.so $(HOST_DIR)$(LUAFILESYSTEM_INSTALL_PATH)
endef

$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
