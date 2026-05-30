################################################################################
#
# argparse
#
################################################################################

ARGPARSE_VERSION = 0.7.1
ARGPARSE_SOURCE = argparse-$(ARGPARSE_VERSION).tar.gz
#ARGPARSE_SITE = https://github.com/luarocks/argparse/archive/
ARGPARSE_SITE = $(DLINK_STORAGE)
ARGPARSE_LICENSE = MIT
ARGPARSE_LICENSE_FILES = LICENSE

ARGPARSE_INSTALL_PATH = "/usr/share/lua/$(BR2_PACKAGE_LUAINTERPRETER_ABI_VERSION)/argparse.lua"

define ARGPARSE_INSTALL_STAGING_CMDS
	$(INSTALL) -m 0644 -D $(@D)/src/argparse.lua $(STAGING_DIR)$(ARGPARSE_INSTALL_PATH)
endef

define ARGPARSE_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0644 -D $(@D)/src/argparse.lua $(TARGET_DIR)$(ARGPARSE_INSTALL_PATH)
endef

define HOST_ARGPARSE_INSTALL_CMDS
	$(INSTALL) -m 0644 -D $(@D)/src/argparse.lua $(HOST_DIR)$(ARGPARSE_INSTALL_PATH)
endef


$(eval $(call GENTARGETS))
$(eval $(call GENTARGETS,host))
