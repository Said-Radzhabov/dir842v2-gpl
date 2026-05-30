# модуль включения mroute опций в профиле ядра.

#Процедура установки необходимых опций mroute.
define IPV6_MROUTE_ENABLE
	@$(call MESSAGE,"Enabling kernel mroute support")
	@$(call KCONFIG_ENABLE_OPT,CONFIG_IPV6_MROUTE,$(LINUX_CONFIG))
	@$(call KCONFIG_DISABLE_OPT_IF_NOT_ENABLED,CONFIG_IPV6_MROUTE_MULTIPLE_TABLES,$(LINUX_CONFIG))
	@$(call KCONFIG_DISABLE_OPT_IF_NOT_ENABLED,CONFIG_IPV6_PIMSM_V2,$(LINUX_CONFIG))
endef

LINUX_ADDONS += $(if $(BR2_PACKAGE_IMPROXY),IPV6_MROUTE_ENABLE)
