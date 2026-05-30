
# set IPIP modules in kernel

define IPIP_ENABLE
@$(call MESSAGE,Enabling kernel IPIP modules [NET_IPIP])
@$(call KCONFIG_ENABLE_OPT_IF_DISABLED,CONFIG_NET_IPIP,m,$(LINUX_CONFIG))
endef

LINUX_ADDONS += $(if $(BR2_SUPPORT_IPIP),IPIP_ENABLE)
