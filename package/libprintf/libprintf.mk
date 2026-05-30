#############################################################
#
# libprintf
#
#############################################################
LIBPRINTF_VERSION = master
LIBPRINTF_SITE = $(DLINK_GIT_STORAGE)/printf
LIBPRINTF_INSTALL_STAGING = YES
LIBPRINTF_LICENSE = MIT
LIBPRINTF_LICENSE_FILES = LICENSE
LIBPRINTF_SUPPORTS_IN_SOURCE_BUILD = NO

LIBPRINTF_CONF_OPT += -DPTR_MAC=ON -DPTR_IP4=ON -DPTR_IP6=ON

$(eval $(call CMAKETARGETS))
