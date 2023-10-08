include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/download.mk

PKG_NAME:=lib-bacnet
PKG_SOURCE_VERSION:=7.5.1
PKG_VERSION:=2.0

include $(INCLUDE_DIR)/package.mk

define Package/lib-bacnet
	SECTION:=net
	CATEGORY:=Network
	PKG_TLT_NAME=lib-bacnet
	TITLE:=BACnet library
	DEPENDS:= +libstdcpp +libpthread +librt +libuci +libtlt_uci
endef

define Package/lib-bacnet/description
	Bacnet stack library for bacnet applications
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib $(1)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/ipkg-install/usr/lib/*.so $(STAGING_DIR)/usr/lib/
endef


define Package/lib-bacnet/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ipkg-install/usr/lib/libbacnet.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,lib-bacnet))
