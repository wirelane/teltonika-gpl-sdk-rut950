APP_NAME?=$(notdir ${CURDIR})
APP_SECTION?=vuci
APP_CATEGORY?=VuCI

PKG_NAME?=$(APP_NAME)
PKG_RELEASE?=1

GPL_INCLUDE_SRC?=1

include $(INCLUDE_DIR)/package.mk
include ../utils.mk


define Package/$(PKG_NAME)
	SECTION:=$(APP_SECTION)
	CATEGORY:=$(APP_CATEGORY)
	SUBMENU:=Applications/API
	TITLE:=$(if $(APP_TITLE),$(APP_TITLE),$(APP_NAME))
	DEPENDS:=$(APP_DEPENDS) +api-core
endef

define Build/Prepare
	if [[ -d ./files ]] && [[ "$$$$(ls -A ./files)" ]]; then $(CP) -R ./files $(PKG_BUILD_DIR)/files; fi
	# only called if pkg has .c files in ./src dir to copy
	if [[ -d ./src ]] && [[ "$$$$(ls -A ./src)" ]]; then $(CP) ./src/* $(PKG_BUILD_DIR)/; fi
endef

define Build/Compile
  $(call CompileLua,$(PKG_BUILD_DIR)/files)
	# only called if pkg has .c files in ./src dir (or ./bin for GPL build) to compile 
	if [[ -d ./src && "$$$$(ls -A ./src)" ]] || [[ -d ./bin && "$$$$(ls -A ./bin)" ]]; then ( $(call Build/Compile/Default) ); fi
endef

define Build/Configure
endef

define Package/$(PKG_NAME)/install/Default
	if [[ -n "$(CONFIG_VUCI_COMPILE_LUA)" ]] && [[ -d $(PKG_BUILD_DIR)/files ]]; then $(CP) $(PKG_BUILD_DIR)/files/* $(1)/; elif [[ -d ./files ]]; then $(CP) ./files/* $(1)/; fi
	$(if $(CONFIG_VUCI_MINIFY_JSON),$(call JsonMin,$(1)/),true);
endef

define Build/InstallGPL
	$(Build/InstallGPL/Default)
	if [[ -z "$(CONFIG_GPL_INCLUDE_WEB_SOURCES)" ]] && [[ -d $(PKG_BUILD_DIR)/files ]]; then $(INSTALL_DIR) $(1); rm -rf $(1)/files $(1)/tests ; $(CP) -R $(PKG_BUILD_DIR)/files $(1); fi
endef

ifndef Package/$(PKG_NAME)/install
define Package/$(PKG_NAME)/install
$(call Package/$(PKG_NAME)/install/Default,$(1))
endef
endif

ifneq ($(CUSTOM_INSTALL),1)
$(eval $(call BuildPackage,$(PKG_NAME)))
endif
