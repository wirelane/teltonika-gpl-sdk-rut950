#
# Copyright (C) 2022 Teltonika-Networks
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vuci-ui-core
PKG_VERSION:=2023-10-02-1c2930a849
PKG_RELEASE:=2

PKG_BUILD_PARALLEL:=1
VUCI_APPS=$(shell grep ^CONFIG_PACKAGE_vuci-app.*-ui=y $(TOPDIR)/.config | cut -d'=' -f1 | cut -d'_' -f3 | sed ':a;N;$!ba;s/\n/ /g')
VUCI_PLUGINS=$(shell grep ^CONFIG_PACKAGE_vuci-app.*-ui=m $(TOPDIR)/.config | cut -d'=' -f1 | cut -d'_' -f3 | sed ':a;N;$!ba;s/\n/ /g')

# PKG_BUILD_DEPENDS:=VUCI_USE_VUCI_NODE:vuci-node/host VUCI_USE_OW_NODE:node/host

PKG_CONFIG_DEPENDS:=CONFIG_VUCI_USE_HOST_NODE CONFIG_VUCI_BUILD_DEV #CONFIG_VUCI_USE_VUCI_NODE

# used for GPL app file path modification
APP_DIR=$(1)

include $(INCLUDE_DIR)/package.mk
include ../utils.mk

define Package/vuci-ui-core
	SECTION:=webui
	CATEGORY:=WebUI
	TITLE:=vuci ui core
	DEPENDS:=+api-core
endef

define Package/vuci-ui-core/description
	Provides core ui for VuCI
endef

define Package/vuci-ui-core/config
	source "$(SOURCE)/Config.in"
endef

define Package/vuci-ui-core/conffiles
/etc/config/widget
endef

define install_closed_gpl
	rm -rf ~/.npm/
	mv $(PKG_BUILD_DIR)/src/views/system/FwVerify.vue \
		$(PKG_BUILD_DIR)/src/views/system/FwVerify_temp.vue

	mv $(PKG_BUILD_DIR)/src/views/system/FwVerifyGPL.vue \
		$(PKG_BUILD_DIR)/src/views/system/FwVerify.vue

	mv $(PKG_BUILD_DIR)/ui-core/plugins/brand/index.js \
		$(PKG_BUILD_DIR)/ui-core/plugins/brand/index_temp.js

	mv $(PKG_BUILD_DIR)/ui-core/plugins/brand/index_gpl.js \
		$(PKG_BUILD_DIR)/ui-core/plugins/brand/index.js

	$(CP) "$(PKG_BUILD_DIR)/ui-core/plugins/brand/brand.json" \
		"$(PKG_BUILD_DIR)/public/brand"

	$(CP) "$(PKG_BUILD_DIR)/ui-core/plugins/brand/brand.json" \
		"$(PKG_BUILD_DIR)/dist/brand"

	$(MAKE) -C $(PKG_BUILD_DIR)

	mv $(PKG_BUILD_DIR)/src/views/system/FwVerify.vue \
		$(PKG_BUILD_DIR)/src/views/system/FwVerifyGPL.vue

	mv $(PKG_BUILD_DIR)/src/views/system/FwVerify_temp.vue \
		$(PKG_BUILD_DIR)/src/views/system/FwVerify.vue

	$(CP) -rf ./files $(PKG_GPL_BUILD_DIR)
	$(CP) -rf "$(PKG_BUILD_DIR)/dist" $(1)

	mv $(PKG_BUILD_DIR)/ui-core/plugins/brand/index.js \
		$(PKG_BUILD_DIR)/ui-core/plugins/brand/index_gpl.js

	mv $(PKG_BUILD_DIR)/ui-core/plugins/brand/index_temp.js \
		$(PKG_BUILD_DIR)/ui-core/plugins/brand/index.js

	rm "$(PKG_BUILD_DIR)/public/brand/brand.json"

	rm "$(PKG_BUILD_DIR)/dist/brand/brand.json"

	$(CP) ../compile-app-gpl.sh "$(GPL_BUILD_DIR)/package/feeds/vuci/"
endef


define Build/Clean
	@$(shell [ -d $(BUILD_DIR)/.vuci-build-plugin ] && rm -r $(BUILD_DIR)/.vuci-build-plugin)
	@$(shell [ -L $(BUILD_DIR)/.vuci-build-plugin ] && rm $(BUILD_DIR)/.vuci-build-plugin)
endef



ifneq ($(CONFIG_VUCI_BUILD_DEV),)
	MAKE_VARS = NODE_ENV=development
endif

ifneq ($(CONFIG_VUCI_USE_HOST_NODE),)
	NODE_EXTRA_PATH =
	ifneq ($(CONFIG_VUCI_NODE_EXTRA_BIN_PATH),)
		NODE_EXTRA_PATH:=":$(CONFIG_VUCI_NODE_EXTRA_BIN_PATH)"
	endif
	NODE_PATH=$(shell PATH=/usr/bin:/usr/local/bin$(NODE_EXTRA_PATH) which node)
	NPM_PATH=$(shell PATH=/usr/bin:/usr/local/bin$(NODE_EXTRA_PATH) which npm)
	ifneq ($(NODE_PATH),)
		MAKE_VARS += NODE=$(NODE_PATH)
	endif
	ifneq ($(NPM_PATH),)
		MAKE_VARS += NPM=$(NPM_PATH)
	endif
else
	MAKE_VARS += NODE=$(STAGING_DIR_HOSTPKG)/bin/node
	MAKE_VARS += NPM=$(STAGING_DIR_HOSTPKG)/bin/npm
endif

define Package/vuci-ui-core/install
	$(INSTALL_DIR) $(1)/www
	$(CP) $(PKG_BUILD_DIR)/dist/* $(1)/www/
	if [ ! -z "$$$$(ls ./modem-icons/$(TLT_PLATFORM_NAME)*)" ]; then \
		$(CP) ./modem-icons/$(TLT_PLATFORM_NAME)* $(1)/www/tlt-icons/modem-icons/; \
	fi
	$(CP) ./files/* $(1)/
	$(if $(CONFIG_VUCI_MINIFY_JSON),$(call JsonMin,$(1)/),true);

	$(if $(CONFIG_DUAL_SIM_SUPPORT),, \
		$(RM) $(1)/www/tlt-icons/modem-icons/simcard-secondary.svg; \
	)
	$(if $(CONFIG_MOBILE_SUPPORT),, \
		$(RM) -r $(1)/www/tlt-icons/modem-icons; \
		$(RM) $(1)/www/tlt-icons/mobile.svg \
		$(RM) $(1)/www/tlt-icons/side-sim.svg; \
		$(RM) $(1)/www/tlt-icons/signal*.png; \
		$(RM) $(1)/www/tlt-icons/sim-*.svg; \
	)
	$(if $(CONFIG_BLUETOOTH_SUPPORT),, \
		$(RM) $(1)/www/tlt-icons/side-bluetooth.svg; \
	)
	$(if $(CONFIG_WIFI_SUPPORT),, \
		$(RM) $(1)/www/tlt-icons/side-navbar/wireless.svg; \
		$(RM) $(1)/www/tlt-icons/side-navbar/wireless.svg.gz; \
		$(RM) $(1)/www/tlt-icons/side-wifi.svg; \
		$(RM) $(1)/www/tlt-icons/wifi*.png; \
		$(RM) $(1)/www/tlt-icons/wifi*.svg; \
		$(RM) $(1)/www/tlt-icons/wifi*.svg.gz; \
	)
	$(if $(CONFIG_SPEEDTEST_SUPPORT),, \
		$(RM) $(1)/www/tlt-icons/speedtest_*.svg; \
	)
	$(if $(TLT_PLATFORM_TSW2), \
		$(RM) -r $(1)/www/tlt-icons/signal-bars; \
		$(RM) $(1)/www/tlt-icons/connection-big-*.svg; \
	)

endef

define Package/vuci-ui-core/postinst
#!/bin/sh
[ -z "$${IPKG_INSTROOT}" ] && exit 0

uci batch <<-EOF
	set uhttpd.main.ubus_prefix="/ubus"
	set uhttpd.main.index_page='cgi-bin/luci'
	set uhttpd.main.error_page="/404.html"
	commit uhttpd
EOF
/etc/init.d/uhttpd restart
/etc/init.d/rpcd restart
exit 0
endef

$(eval $(call BuildPackage,vuci-ui-core))
