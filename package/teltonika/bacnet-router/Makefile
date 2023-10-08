include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/download.mk

PKG_NAME:=bacnet-router
PKG_SOURCE_VERSION:=1.2

include $(INCLUDE_DIR)/package.mk

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bacnet-router $(1)/usr/sbin/bacnet-router
endef

define Package/bacnet-router
	SECTION:=net
	CATEGORY:=Network
	PKG_TLT_NAME=BACnet Router
	PKG_ROUTER:=$(TLT_PLATFORM_NAME)
	TITLE:=BACnet IP MS/TP serial gateway (router) application
	DEPENDS:= +libstdcpp +libpthread +librt +libuci +libtlt_uci +lib-bacnet +vuci-app-bacnet-ui
endef

define Package/bacnet-router/teltonika_rut9xx
  PKG_ROUTER:=RUT955
endef

define Package/bacnet-router/teltonika_rut9m
  PKG_ROUTER:=RUT956 RUT906
endef

define Package/bacnet-router/mdm9x07
  PKG_ROUTER:=TRB145
endef

define Package/bacnet-router/teltonika_trb2xx
  PKG_ROUTER:=TRB245 TRB255
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/bacnet_router
endef

define Package/bacnet-router/description
	Bacnet router application for communication between BACnet IP and MS/TP serial networks
endef

define Package/bacnet-router/prerm
	#!/bin/sh
	. /lib/functions.sh
	remove_bbmd_rule() {
		config_get name "$$1" name ""
		[ "$$name" = "BACnet" ] && uci_remove firewall "$$1"
	}
	config_load 'firewall'
	config_foreach remove_bbmd_rule "redirect"
	uci_commit network
endef


define Package/bacnet-router/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bacnet-router $(1)/usr/sbin/bacnet-router
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/bacnet_router.init $(1)/etc/init.d/bacnet_router
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/bacnet_router.config $(1)/etc/config/bacnet_router
endef

$(eval $(call BuildPackage,bacnet-router))
