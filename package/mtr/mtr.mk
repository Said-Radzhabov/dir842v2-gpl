################################################################################
#
# mtr
#
################################################################################

MTR_VERSION = 0.93
# MTR_SITE = $(call github,traviscross,mtr,v$(MTR_VERSION))
MTR_SITE = $(DLINK_STORAGE)
MTR_AUTORECONF = YES
MTR_CONF_OPT = --without-gtk $(if $(BR2_PACKAGE_NCURSES),,--without-ncurses)
MTR_DEPENDENCIES = host-pkg-config $(if $(BR2_PACKAGE_NCURSES),ncurses)
MTR_LICENSE = GPL-2.0
MTR_LICENSE_FILES = COPYING
MTR_SELINUX_MODULES = netutils

$(eval $(call AUTOTARGETS))
