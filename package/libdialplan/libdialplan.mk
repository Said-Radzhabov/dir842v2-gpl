#############################################################
#
# libdialplan
#
#############################################################

LIBDIALPLAN_VERSION = master
LIBDIALPLAN_SITE = $(DLINK_GIT_STORAGE)/libdialplan
LIBDIALPLAN_INSTALL_STAGING = YES
LIBDIALPLAN_LICENSE = MIT
LIBDIALPLAN_LICENSE_FILES = LICENSE.txt

$(eval $(call CMAKETARGETS))
