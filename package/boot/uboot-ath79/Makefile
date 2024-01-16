#
# Copyright (C) 2023 Teltonika-Networks
#

include $(TOPDIR)/rules.mk

PKG_NAME:=uboot-ath79

PKG_SOURCE_VERSION:=4.3.1

PKG_LICENSE:=LGPL-2.1
PKG_ORIGIN_URL:=https://github.com/pepe2k/u-boot_mod

include $(INCLUDE_DIR)/package.mk

define Package/uboot-ath79
	SECTION:=boot
	CATEGORY:=Boot Loaders
	TITLE:=U-Boot for ath79/mt7628 based boards
endef

OVERRIDE_PATH := /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

define Build/Compile
	$(foreach dev,$(CONFIG_TARGET_BOOT_NAME),\
		env -i PATH=$(OVERRIDE_PATH) \
			$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
				BUILD_TOPDIR=$(PKG_BUILD_DIR) \
				CROSS_COMPILE=$(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS) \
					clean $(call qstrip,$(dev));)
endef

define Package/uboot-ath79/install
	$(foreach dev,$(CONFIG_TARGET_BOOT_NAME),\
		filename=$$$$(basename $(PKG_BUILD_DIR)/bin/u-boot_$(call qstrip,$(dev))_*.md5 | rev | cut -c 5- | rev); \
		$(CP) $(PKG_BUILD_DIR)/bin/$$$${filename}.bin $(BIN_DIR)/u-boot_$(call qstrip,$(dev)).bin; \
		$(CP) $(PKG_BUILD_DIR)/bin/$$$${filename}_webui.bin $(BIN_DIR)/u-boot_$(call qstrip,$(dev))_webui.bin;)
	$(CP) $(PKG_BUILD_DIR)/version $(BIN_DIR)/u-boot_version
endef

$(eval $(call BuildPackage,uboot-ath79))
