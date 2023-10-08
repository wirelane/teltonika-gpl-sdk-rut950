include $(TOPDIR)/rules.mk

THEME_NAME=default
PKG_NAME:=hs_theme_$(THEME_NAME)
PKG_VERSION:=2022-07-27
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk


define Package/tlt_hs_theme_$(THEME_NAME)
	SECTION:=webui
	CATEGORY:=WebUI
	SUBMENU:=Landing page themes
	TITLE:=Default theme
	DEPENDS:=+vuci-app-landingpage
endef

define Package/tlt_hs_theme_$(THEME_NAME)/description
	Hotspot landing page default theme.
endef

define Package/tlt_hs_theme_$(THEME_NAME)/prerm
	#!/bin/sh

	[[ -e "/usr/lib/opkg/info/coova-chilli.control" ]] || {
		uci -q delete landingpage.$(THEME_NAME)
		uci set landingpage.general.theme="default"
		uci -q commit
		[[ -d "/hotspotlogin/backup" ]] && rm -rf /hotspotlogin/backup/
		exit 0
	}

	[[ "$$(uci -q get landingpage.general.theme)" == "$(THEME_NAME)" ]] && {
		echo "ret: Theme already in use"
		exit 1
	}

	uci -q delete landingpage.$(THEME_NAME)
	uci -q commit

	[[ -d "/hotspotlogin/backup" ]] && rm -rf /hotspotlogin/backup/
	exit 0
endef

define Package/tlt_hs_theme_$(THEME_NAME)/postinst
	#!/bin/sh

	[[ "$$(uci -q get landingpage.$(THEME_NAME))" == "" ]] && {
		uci set landingpage.default=theme
		uci set landingpage.default.name="Default theme"
		uci -q commit landingpage
	}

	[[ -d "/rom/hotspotlogin" ]] || {
		mkdir -p /hotspotlogin/backup/themes/default /hotspotlogin/backup/cgi-bin/themes/default
		cp -rf /hotspotlogin/themes/default/style /hotspotlogin/backup/themes/default/
		cp -rf /hotspotlogin/cgi-bin/themes/default /hotspotlogin/backup/cgi-bin/themes/
	}

	exit 0
endef



define Package/tlt_hs_theme_$(THEME_NAME)/install
	$(INSTALL_DIR) $(1)/hotspotlogin
	$(CP) files/hotspotlogin/* $(1)/hotspotlogin/
endef

$(eval $(call BuildPackage,tlt_hs_theme_$(THEME_NAME)))
