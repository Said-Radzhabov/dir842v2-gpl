#############################################################
#
# libnl
#
#############################################################

LIBNL_VERSION = $(call qstrip,$(BR2_PACKAGE_LIBNL_VERSION))
LIBNL_SITE = ${DLINK_GIT_STORAGE}/libnl
LIBNL_LICENSE = LGPL-2.1+
LIBNL_LICENSE_FILES = COPYING
LIBNL_INSTALL_STAGING = YES
LIBNL_DEPENDENCIES = host-bison host-flex host-pkg-config

ifeq ($(BR2_PACKAGE_LIBNL_TOOLS),y)
LIBNL_CONF_OPT += --enable-cli
else
LIBNL_CONF_OPT += --disable-cli
endif

LIBNL_CONF_OPT += --disable-unit-tests

$(eval $(call AUTOTARGETS))
