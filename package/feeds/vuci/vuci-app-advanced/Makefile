include $(TOPDIR)/rules.mk

PKG_NAME:=vuci-advanced-mode
PKG_RELEASE:=1
GPL_INCLUDE_SRC:=1

include $(INCLUDE_DIR)/package.mk

define Package/vuci-advanced-mode
    SECTION:=vuci
    CATEGORY:=VuCI
    SUBMENU:=ui-core
    TITLE:=VuCI advanced mode support files
    DEPENDS:= +vuci-ui-core
endef

define Build/Compile
    true
endef

define Package/vuci-advanced-mode/install
	$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,vuci-advanced-mode))