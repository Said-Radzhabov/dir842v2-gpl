#############################################################
#
# snmp
#
#############################################################
NET_SNMP_VERSION = 5.7.3
NET_SNMP_SITE = ${DLINK_GIT_STORAGE}/net-snmp
NET_SNMP_LICENSE = MIT-CMU AND BSD-3-Clause
NET_SNMP_LICENSE_FILES = COPYING

NET_SNMP_INSTALL_STAGING = YES
NET_SNMP_INSTALL_TARGET = YES

NET_SNMP_DEPENDENCIES = openssl

NET_SNMP_MIB_MODULES_INCLUDED = \
        if-mib/ifXTable \
        mibII/at \
        mibII/icmp \
        mibII/ifTable \
        mibII/ip \
        mibII/snmp_mib \
        mibII/sysORTable \
        mibII/system_mib \
        mibII/tcp \
        mibII/udp \
        mibII/vacm_context \
        mibII/vacm_vars \
        snmpv3/snmpEngine \
        snmpv3/snmpMPDStats \
        snmpv3/usmConf \
        snmpv3/usmStats \
        snmpv3/usmUser \
        util_funcs

ifeq ($(BR2_SUPPORT_ADSL),y)
NET_SNMP_MIB_MODULES_INCLUDED += dsl/adsl
endif

ifeq ($(BR2_SUPPORT_VDSL),y)
NET_SNMP_MIB_MODULES_INCLUDED += dsl/vdsl
endif

ifeq ($(BR2_PACKAGE_NET_SNMP_DLINK_BALTCOM_MIBS),y)
NET_SNMP_MIB_MODULES_INCLUDED += dlink/baltcom
endif

NET_SNMP_MIB_MODULES_EXCLUDED = \
        agent_mibs \
        agentx \
        disman/event \
        disman/schedule \
        hardware \
        host \
        if-mib \
        mibII \
        notification \
        notification-log-mib \
        snmpv3mibs \
        target \
        tcp-mib \
        ucd_snmp \
        udp-mib \
        utilities \
        host/hr_device \
        host/hr_disk \
        host/hr_filesys \
        host/hr_network \
        host/hr_partition \
        host/hr_proc \
        host/hr_storage \
        host/hr_system \
        tunnel \
        ucd-snmp/disk \
        ucd-snmp/dlmod \
        ucd-snmp/extensible \
        ucd-snmp/loadave \
        ucd-snmp/memory \
        ucd-snmp/pass \
        ucd-snmp/proc \
        ucd-snmp/vmstat \
        utilities/execute

NET_SNMP_TRANSPORTS_INCLUDED = TCP UDP

NET_SNMP_TRANSPORTS_EXCLUDED = Callback TCPIPv6 Unix

NET_SNMP_CONF_OPT += \
        --without-perl-modules\
        --disable-embedded-perl\
        --disable-perl-cc-checks\
        --enable-mfd-rewrites \
        --enable-static \
        --with-logfile=/var/log/snmpd.log \
        --with-persistent-directory=/usr/lib/snmp/ \
        --with-default-snmp-version=3 \
        --with-sys-contact=root@localhost \
        --with-sys-location=Unknown \
        --enable-agent\
        --disable-applications \
        --disable-debugging \
        --disable-manuals \
        --disable-scripts \
        --disable-mibs \
        --with-out-mib-modules="$(NET_SNMP_MIB_MODULES_EXCLUDED)" \
        --with-mib-modules="$(NET_SNMP_MIB_MODULES_INCLUDED)" \
        --with-out-transports="$(NET_SNMP_TRANSPORTS_EXCLUDED)" \
        --with-transports="$(NET_SNMP_TRANSPORTS_INCLUDED)" \
        --without-libwrap \
        --without-rpm \
        --without-zlib

NET_SNMP_CONF_ENV += LIBS='-Wl,-rpath-link,$(STAGING_DIR)/lib -Wl,-rpath-link,$(STAGING_DIR)/usr/lib -ld_service_notify -ljansson'
NET_SNMP_DEPENDENCIES += deuteron_framework

# TODO: с этой опцией не собирается SNMP
# ifeq (${BR2_INET_IPV6},y)
# NET_SNMP_CONF_OPT += --with_ipv6
# endif

NET_SNMP_MAKE = $(MAKE1)

NET_SNMP_LUA_FILES :=

ifeq ($(BR2_PACKAGE_NET_SNMP_DLINK_DSL_STATISTICS),y)
NET_SNMP_LUA_FILES += agent/mibgroup/dsl/dsl_statistics.lua
endif

ifeq ($(BR2_PACKAGE_NET_SNMP_DLINK_BALTCOM_MIBS),y)
NET_SNMP_LUA_FILES += agent/mibgroup/dlink/baltcom.lua
endif

define NET_SNMP_INSTALL_LUA_MODULES
	mkdir -p $(TARGET_DIR)/usr/share/snmp
	$(foreach lua_file,$(NET_SNMP_LUA_FILES),cp $(@D)/$(lua_file) $(TARGET_DIR)/usr/share/snmp)
endef

NET_SNMP_POST_INSTALL_TARGET_HOOKS += NET_SNMP_INSTALL_LUA_MODULES


$(eval $(call AUTOTARGETS))

