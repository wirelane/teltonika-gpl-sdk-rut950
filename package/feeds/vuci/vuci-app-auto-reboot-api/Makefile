include $(TOPDIR)/rules.mk

APP_TITLE:=VuCI API Support for Auto Reboot

CUSTOM_INSTALL=1
include ../api.mk

define Package/$(PKG_NAME)/install
	$(call Package/$(PKG_NAME)/install/Default,$(1))
	$(if $(CONFIG_AP_DEVICE),\
		$(RM) $(1)/usr/share/rpcd/acl.d/autoreboot.json,\
		$(RM) $(1)/usr/share/rpcd/acl.d/autoreboot_system.json)
endef

# call BuildPackage - OpenWrt buildroot signature
$(eval $(call BuildPackage,$(PKG_NAME)))