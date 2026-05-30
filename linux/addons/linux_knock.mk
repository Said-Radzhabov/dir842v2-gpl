
# включаем модуль NetFilter Recent в профиле ядра.

define RECENT_ENABLE
@$(call MESSAGE,"Enabling kernel netfilter module recent")
@$(call KCONFIG_ENABLE_OPT,CONFIG_NETFILTER_XT_MATCH_RECENT,$(LINUX_CONFIG))
endef

LINUX_ADDONS += $(if $(BR2_TELNET_SSH_PROTECT),RECENT_ENABLE,)
