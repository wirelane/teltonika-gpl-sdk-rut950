include $(TOPDIR)/rules.mk

APP_TITLE:=VuCI UI Support for Cloud Solutions

CUSTOM_INSTALL=1
include ../app.mk

define Package/$(PKG_NAME)/install
	$(call Package/$(PKG_NAME)/install/Default,$(1))
	$(if $(CONFIG_AP_DEVICE),\
		$(RM) $(1)/usr/share/vuci/menu.d/cloudsolutions.json,\
		$(RM) $(1)/usr/share/vuci/menu.d/cloudsolutions_system.json)
endef


# call BuildPackage - OpenWrt buildroot signature
$(eval $(call BuildPackage,$(PKG_NAME)))
