################################################################################
#
# zabbix
#
################################################################################

ZABBIX_VERSION = 2.4.3
# ZABBIX_SITE = https://sourceforge.net/projects/zabbix/files
ZABBIX_SITE = $(DLINK_STORAGE)
ZABBIX_LICENSE = GPL-2.0
ZABBIX_LICENSE_FILES = README

ZABBIX_DEPENDENCIES = pcre libiconv

ZABBIX_CONF_OPT = --with-libpcre=$(STAGING_DIR)/usr/bin/ \
	--enable-agent \
	--disable-java
ZABBIX_CONF_ENV = ac_cv_header_sys_sysinfo_h=no

ZABBIX_POST_INSTALL_TARGET_HOOKS += ZABBIX_CLIENT_CHANGE_PIDFILE_LOCATION

define ZABBIX_CLIENT_CHANGE_PIDFILE_LOCATION
	$(SED) 's%\#\ PidFile=/tmp/zabbix_agentd.pid%PidFile=/run/zabbix/zabbix_agentd.pid%g' $(TARGET_DIR)/etc/zabbix_agentd.conf
endef

ZABBIX_POST_INSTALL_TARGET_HOOKS += ZABBIX_CLIENT_DELETE_CONFIG

define ZABBIX_CLIENT_DELETE_CONFIG
	$(Q)rm -rf $(TARGET_DIR)/etc/zabbix_agent*
endef

$(eval $(call AUTOTARGETS))
