################################################################################
#
# teal
#
################################################################################

TEAL_VERSION = 0.13.1
TEAL_SOURCE  = teal-language-$(TEAL_VERSION).tar.gz
TEAL_SITE    = $(DLINK_STORAGE)
TEAL_LICENSE = MIT
TEAL_LICENSE_FILES = LICENSE

HOST_TEAL_DEPENDENCIES = host-lua host-luafilesystem host-argparse

define HOST_TEAL_INSTALL_CMDS
	$(INSTALL) -m 0755 -D $(@D)/tl     $(HOST_DIR)/usr/bin/tl
	$(INSTALL) -m 0755 -D $(@D)/tl.tl  $(HOST_DIR)/usr/share/lua/$(BR2_PACKAGE_LUAINTERPRETER_ABI_VERSION)/tl.tl
	$(INSTALL) -m 0755 -D $(@D)/tl.lua $(HOST_DIR)/usr/share/lua/$(BR2_PACKAGE_LUAINTERPRETER_ABI_VERSION)/tl.lua
endef

define HOST_TEAL_UNINSTALL_CMDS
	rm -f $(HOST_DIR)/usr/bin/tl
	rm -f $(HOST_DIR)/usr/share/lua/$(BR2_PACKAGE_LUAINTERPRETER_ABI_VERSION)/tl.tl
	rm -f $(HOST_DIR)/usr/share/lua/$(BR2_PACKAGE_LUAINTERPRETER_ABI_VERSION)/tl.lua
endef

$(eval $(call GENTARGETS,host))

