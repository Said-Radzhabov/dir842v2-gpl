#############################################################
#
# iw
#
#############################################################

IW_VERSION = $(call qstrip,$(BR2_IW_VERSION))
IW_SITE = ${DLINK_GIT_STORAGE}/iw
IW_LICENSE = ISC
IW_LICENSE_FILES = COPYING

IW_CFLAGS =
IW_LDFLAGS = $(TARGET_LDFLAGS)
IW_MAKE_ENV =

ifeq ($(BR2_PACKAGE_LIBNL),y)
IW_DEPENDENCIES += libnl
IW_CFLAGS += -I$(STAGING_DIR)/include/libnl3 -DCONFIG_LIBNL30
IW_MAKE_ENV += NLLIBNAME="libnl-3.0" LIBS="-lnl-3 -lnl-genl-3"
else
IW_DEPENDENCIES += libnl-tiny
IW_CFLAGS += -I$(STAGING_DIR)/usr/include/libnl-tiny -DCONFIG_LIBNL20 -D_GNU_SOURCE
IW_MAKE_ENV += NLLIBNAME="libnl-tiny" LIBS="-lm -lnl-tiny"
endif

IW_MAKE_ENV += \
	NO_PKG_CONFIG=Y \
	CC="$(TARGET_CC)" \
	LD="$(TARGET_LD)" \
	CFLAGS="$(IW_CFLAGS)" \
	LDFLAGS="$(IW_LDFLAGS)" \
	V=1

define IW_CONFIGURE_CMDS
	echo "const char iw_version[] = \"$(IW_VERSION)\";" > $(@D)/version.c
	echo "#!/bin/sh" > $(@D)/version.sh
	chmod +x $(@D)/version.sh
endef

define IW_BUILD_CMDS
	$(IW_MAKE_ENV) $(MAKE) -C $(@D)
endef

define IW_INSTALL_TARGET_CMDS
	$(IW_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef


$(eval $(call GENTARGETS))
