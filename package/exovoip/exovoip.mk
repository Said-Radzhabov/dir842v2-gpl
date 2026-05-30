#############################################################
#
# exovoip
#
#############################################################

EXOVOIP_VERSION = $(call qstrip,$(BR2_PACKAGE_EXOVOIP_BRANCH))
EXOVOIP_SITE = $(DLINK_GIT_STORAGE)/exovoip
EXOVOIP_INSTALL_STAGING = NO
EXOVOIP_DEPENDENCIES = libosip2 libeXosip2 libdialplan jansson deuteron_framework
EXOVOIP_CONF_OPT += -DSDK2_SUPPORT=ON
EXOVOIP_LICENSE = GPL-2.0-or-later
EXOVOIP_LICENSE_FILES = LICENSE.txt

$(eval $(call CMAKETARGETS))
