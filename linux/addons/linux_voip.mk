# Модуль настройки поддержки DSCP разметки для RTP пакетов в демоне exovoip

# Задает дефайн для включения в структуру конфига RTP траффика переменной tos в ядре и libvoip_manager-е
define EXOVOIP_ENABLE
        @$(call MESSAGE,"Enabling kernel CONFIG_RTK_VOIP_RTP_TOS")
        @$(call KCONFIG_ENABLE_OPT,CONFIG_RTK_VOIP_RTP_TOS,$(LINUX_CONFIG))
endef

define EXOVOIP_DISABLE
        @$(call MESSAGE,"Disabling kernel CONFIG_RTK_VOIP_RTP_TOS")
        @$(call KCONFIG_DISABLE_OPT,CONFIG_RTK_VOIP_RTP_TOS,$(LINUX_CONFIG))
endef

LINUX_ADDONS += $(if $(BR2_PACKAGE_EXOVOIP),EXOVOIP_ENABLE,EXOVOIP_DISABLE)
