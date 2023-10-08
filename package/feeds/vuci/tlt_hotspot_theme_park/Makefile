include $(TOPDIR)/rules.mk

THEME_NAME=park
PKG_NAME:=hs_theme_$(THEME_NAME)
PKG_VERSION:=2022-07-27
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk


define Package/$(PKG_NAME)
	PKG_TLT_NAME:=Hotspot landing page $(THEME_NAME) theme
	PKG_ROUTER:=$(TLT_PLATFORM_NAME)
	SECTION:=webui
	CATEGORY:=WebUI
	SUBMENU:=Landing page themes
	TITLE:=Park theme
	DEPENDS:=+vuci-app-landingpage +coova-chilli
endef

define Package/$(PKG_NAME)/description
	Hotspot landing page park theme.
endef

define Package/$(PKG_NAME)/preinst
	#!/bin/sh

	[[ "$$(uci -q get landingpage.$(THEME_NAME))" == "theme" ]] && {
		echo "ret: Theme already exists"
		exit 1
	}

	exit 0
endef

define Package/$(PKG_NAME)/prerm
	#!/bin/sh

	[[ -e "/usr/lib/opkg/info/coova-chilli.control" ]] || {
		uci -q delete landingpage.$(THEME_NAME)
		uci set landingpage.general.theme="default"
		uci -q commit
		exit 0
	}

	[[ "$$(uci -q get landingpage.general.theme)" == "$(THEME_NAME)" ]] && {
		echo "ret: Theme already in use"
		exit 1
	}

	uci -q delete landingpage.$(THEME_NAME)
	uci -q commit

	exit 0
endef

define Package/$(PKG_NAME)/postinst
	#!/bin/sh

	[[ "$$(uci -q get landingpage.$(THEME_NAME))" == "" ]] && {
		uci set landingpage.park=theme
		uci set landingpage.park.name="Park theme"
		uci -q commit landingpage
	}

	exit 0
endef




define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/hotspotlogin
	$(CP) files/hotspotlogin/* $(1)/hotspotlogin/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
