APP_NAME?=$(notdir ${CURDIR})
APP_SECTION?=vuci
APP_CATEGORY?=VuCI

PKG_NAME?=$(APP_NAME)
PKG_RELEASE?=1
PLUGIN_DIR:=$(BUILD_DIR)/.vuci-build-plugin/.plugin/

include $(INCLUDE_DIR)/package.mk
include ../utils.mk

define Package/$(PKG_NAME)
	SECTION:=$(APP_SECTION)
	CATEGORY:=$(APP_CATEGORY)
	SUBMENU:=Applications/UI
	TITLE:=$(if $(APP_TITLE),$(APP_TITLE),$(APP_NAME))
ifndef NO_API_DEPEND
	DEPENDS:=$(APP_DEPENDS) +vuci-ui-core +$(patsubst %-ui,%,$(APP_NAME))-api
else
	DEPENDS:=$(APP_DEPENDS) +vuci-ui-core 
endif
endef

define Build/Configure
endef

packed_src :=
ifneq ($(CONFIG_GPL_BUILD), y)
	packed_src = 1
endif
ifeq ($(CONFIG_GPL_BUILD), y)
ifeq ($(CONFIG_GPL_INCLUDE_WEB_SOURCES), y)
	packed_src = 1
endif
endif

ifndef CLOSED_GPL_INSTALL
define Build/Compile
	if [[ -d ./files ]]; then $(CP) ./files/ $(PKG_BUILD_DIR)/ ; fi
	$(if $(packed_src), \
		$(if $(findstring m,$(CONFIG_PACKAGE_$(PKG_NAME))), \
			$(INSTALL_DIR) $(PLUGIN_DIR)/$(PKG_NAME); \
			$(CP) $(PKG_BUILD_DIR)/* $(PLUGIN_DIR)/$(PKG_NAME); \
			compileFolder=$(PKG_NAME) $(MAKE) -C $(BUILD_DIR)/.vuci-build-plugin/ plugin; \
			$(CP) $(BUILD_DIR)/.vuci-build-plugin/.plugin/dest/$(PKG_NAME) $(PKG_BUILD_DIR)/dest; \
		) \
	, \
		$(Build/Compile/Default) \
	)
endef

define Build/Prepare
	$(if $(packed_src), \
		$(INSTALL_DIR) $(PKG_BUILD_DIR) $(PKG_BUILD_DIR)/src; \
		if [[ -d ./src ]] && [[ ! `ls -1 ./src | wc -l` = 0 ]]; then $(CP) ./src/* $(PKG_BUILD_DIR)/src; fi \
	)
endef
else
define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/src CC="$(HOSTCC)" CXX="$(HOSTCXX)"
	$(RM) -rf $(PKG_BUILD_DIR)/src
endef

define Build/Prepare
	$(INSTALL_DIR) $(PKG_BUILD_DIR) $(PKG_BUILD_DIR)/src; \
	if [[ -d ./src ]] && [[ ! `ls -1 ./src | wc -l` = 0 ]]; then \
		$(CP) ./src/* $(PKG_BUILD_DIR)/src; \
		$(CP) ../compile-app-gpl.sh $(PKG_BUILD_DIR)/src; \
	fi
	if [[ -d ./files ]]; then $(CP) ./files/ $(PKG_BUILD_DIR)/ ; fi
endef
endif

define Build/InstallGPL
	$(if $(CONFIG_GPL_INCLUDE_WEB_SOURCES), \
		$(Build/InstallGPL/Default) , \
		$(INSTALL_DIR) $(PKG_GPL_BUILD_DIR)/files; \
		if [[ -d $(PKG_BUILD_DIR)/files ]] && [[ "$$(ls -A $(PKG_BUILD_DIR)/files)" ]]; then \
			$(CP) $(PKG_BUILD_DIR)/files/* $(PKG_GPL_BUILD_DIR)/files ;\
		fi ; \
		$(if $(findstring m,$(CONFIG_PACKAGE_$(PKG_NAME))), \
			$(INSTALL_DIR) $(1)/dest; \
			$(CP) $(PKG_BUILD_DIR)/dest/* $(1)/dest || true; \
		) \
	)
endef

define Package/$(PKG_NAME)/install/Default
	if [[ -d $(PKG_BUILD_DIR)/files ]] && [[ "$$$$(ls -A $(PKG_BUILD_DIR)/files)" ]]; then $(CP) $(PKG_BUILD_DIR)/files/* $(1) ; fi
	if [[ -d "$(PKG_BUILD_DIR)/dest" ]] && [[ "$$$$(ls -A $(PKG_BUILD_DIR)/dest)" ]]; then \
		$(INSTALL_DIR) $(1)/www/views; \
		$(CP) $(PKG_BUILD_DIR)/dest/* $(1)/www/views; \
	fi
	$(if $(CONFIG_VUCI_MINIFY_JSON),$(call JsonMin,$(1)/),true);
endef

ifndef Package/$(PKG_NAME)/install
define Package/$(PKG_NAME)/install
$(call Package/$(PKG_NAME)/install/Default,$(1))
endef
endif

ifneq ($(CUSTOM_INSTALL),1)
$(eval $(call BuildPackage,$(PKG_NAME)))
endif
