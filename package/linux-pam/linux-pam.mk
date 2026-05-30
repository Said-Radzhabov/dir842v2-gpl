################################################################################
#
# linux-pam
#
################################################################################

LINUX_PAM_VERSION = 1.5.1
LINUX_PAM_SOURCE = Linux-PAM-$(LINUX_PAM_VERSION).tar.xz
#LINUX_PAM_SITE = https://github.com/linux-pam/linux-pam/releases/download/v$(LINUX_PAM_VERSION)
LINUX_PAM_SITE = $(DLINK_STORAGE)
LINUX_PAM_INSTALL_STAGING = YES
LINUX_PAM_CONF_OPT = \
	--disable-prelude \
	--disable-isadir \
	--disable-nis \
	--disable-db \
	--disable-regenerate-docu \
	--enable-securedir=/lib/security \
	--libdir=/usr/lib \
	--includedir=/usr/include/security
LINUX_PAM_DEPENDENCIES = host-flex host-pkg-config \
	$(TARGET_NLS_DEPENDENCIES)
LINUX_PAM_LICENSE = BSD-3-Clause
LINUX_PAM_LICENSE_FILES = Copyright
LINUX_PAM_MAKE_OPTS += LIBS=$(TARGET_NLS_LIBS)

ifeq ($(BR2_SUPPORT_AUTH_CONTROL),y)
LINUX_PAM_CONFIGS_DIR = $(TARGET_DIR)/etc/pam
define LINUX_PAM_CONFIGS_DIR_HOOK
	ln -snf /dev/shm/pam.d $(TARGET_DIR)/etc/pam.d
endef
define LINUX_PAM_REMOTE_LOGIN_PAMFILE_INSTALL
	$(INSTALL) -m 0644 -D package/linux-pam/login.pam \
		$(LINUX_PAM_CONFIGS_DIR)/remote_login
endef
else
LINUX_PAM_CONFIGS_DIR = $(TARGET_DIR)/etc/pam.d
endif

ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
LINUX_PAM_CONF_OPT += --enable-selinux
LINUX_PAM_DEPENDENCIES += libselinux
define LINUX_PAM_SELINUX_PAMFILE_TWEAK
	$(SED) 's/^# \(.*pam_selinux.so.*\)$$/\1/' \
		$(LINUX_PAM_CONFIGS_DIR)/login
endef
else
LINUX_PAM_CONF_OPT += --disable-selinux
endif

ifeq ($(BR2_PACKAGE_AUDIT),y)
LINUX_PAM_CONF_OPT += --enable-audit
LINUX_PAM_DEPENDENCIES += audit
else
LINUX_PAM_CONF_OPT += --disable-audit
endif

# Install default pam config (deny everything except login)
define LINUX_PAM_INSTALL_CONFIG
	$(INSTALL) -m 0644 -D package/linux-pam/login.pam \
		$(LINUX_PAM_CONFIGS_DIR)/login
	$(INSTALL) -m 0644 -D package/linux-pam/other.pam \
		$(LINUX_PAM_CONFIGS_DIR)/other
	$(LINUX_PAM_SELINUX_PAMFILE_TWEAK)
	$(LINUX_PAM_REMOTE_LOGIN_PAMFILE_INSTALL)
endef

LINUX_PAM_CLEANUP_FILES =                         \
	$(TARGET_DIR)/lib/security/pam_debug.so       \
	$(TARGET_DIR)/lib/security/pam_echo.so        \
	$(TARGET_DIR)/lib/security/pam_env.so         \
	$(TARGET_DIR)/lib/security/pam_exec.so        \
	$(TARGET_DIR)/lib/security/pam_faildelay.so   \
	$(TARGET_DIR)/lib/security/pam_filter         \
	$(TARGET_DIR)/lib/security/pam_filter.so      \
	$(TARGET_DIR)/lib/security/pam_ftp.so         \
	$(TARGET_DIR)/lib/security/pam_group.so       \
	$(TARGET_DIR)/lib/security/pam_issue.so       \
	$(TARGET_DIR)/lib/security/pam_keyinit.so     \
	$(TARGET_DIR)/lib/security/pam_lastlog.so     \
	$(TARGET_DIR)/lib/security/pam_limits.so      \
	$(TARGET_DIR)/lib/security/pam_listfile.so    \
	$(TARGET_DIR)/lib/security/pam_localuser.so   \
	$(TARGET_DIR)/lib/security/pam_loginuid.so    \
	$(TARGET_DIR)/lib/security/pam_mail.so        \
	$(TARGET_DIR)/lib/security/pam_mkhomedir.so   \
	$(TARGET_DIR)/lib/security/pam_motd.so        \
	$(TARGET_DIR)/lib/security/pam_namespace.so   \
	$(TARGET_DIR)/lib/security/pam_nologin.so     \
	$(TARGET_DIR)/lib/security/pam_permit.so      \
	$(TARGET_DIR)/lib/security/pam_pwhistory.so   \
	$(TARGET_DIR)/lib/security/pam_rhosts.so      \
	$(TARGET_DIR)/lib/security/pam_rootok.so      \
	$(TARGET_DIR)/lib/security/pam_securetty.so   \
	$(TARGET_DIR)/lib/security/pam_shells.so      \
	$(TARGET_DIR)/lib/security/pam_stress.so      \
	$(TARGET_DIR)/lib/security/pam_succeed_if.so  \
	$(TARGET_DIR)/lib/security/pam_tally2.so      \
	$(TARGET_DIR)/lib/security/pam_tally.so       \
	$(TARGET_DIR)/lib/security/pam_time.so        \
	$(TARGET_DIR)/lib/security/pam_timestamp.so   \
	$(TARGET_DIR)/lib/security/pam_umask.so       \
	$(TARGET_DIR)/lib/security/pam_warn.so        \
	$(TARGET_DIR)/lib/security/pam_wheel.so       \
	$(TARGET_DIR)/lib/security/pam_xauth.so       \
	$(TARGET_DIR)/etc/security

ifeq ($(BR2_SUPPORT_AUTH_CONTROL),y)
LINUX_PAM_CLEANUP_FILES += $(TARGET_DIR)/etc/pam.d/
else
LINUX_PAM_CLEANUP_FILES += $(TARGET_DIR)/lib/security/pam_access.so
endif

define LINUX_PAM_CLEANUP
	rm -vrf $(LINUX_PAM_CLEANUP_FILES)
	$(LINUX_PAM_CONFIGS_DIR_HOOK)
endef

LINUX_PAM_POST_INSTALL_TARGET_HOOKS += LINUX_PAM_INSTALL_CONFIG
LINUX_PAM_POST_INSTALL_TARGET_HOOKS += LINUX_PAM_CLEANUP

$(eval $(call AUTOTARGETS))
