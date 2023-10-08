#
# Copyright (C) 2022 Teltonika
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/download.mk

PKG_NAME:=uboot-ath79
PKG_SOURCE_VERSION:=4.2.0

PKG_LICENSE:=LGPL-2.1
PKG_ORIGIN_URL:=https://github.com/pepe2k/u-boot_mod

include $(INCLUDE_DIR)/package.mk

define Package/uboot-ath79
	SECTION:=boot
	CATEGORY:=Boot Loaders
	TITLE:=pepe2k-uboot for Teltonika ATH79 based boards
endef

OVERRIDE_PATH := /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ifeq ($(CONFIG_BUILD_VERIFIED_BOOT_IMAGE),)
	TARGET_DEVICE := $(if $(CONFIG_TARGET_ath79_24kc_DEVICE_teltonika_trb2xx),tlt-trb24x,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ramips_mt76x8_DEVICE_teltonika_trb2m),tlt-trb2m,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ath79_24kc_DEVICE_teltonika_rut30x),tlt-rut300,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ramips_mt76x8_DEVICE_teltonika_rut301),tlt-rut301,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ath79_24kc_DEVICE_teltonika_rut36x),tlt-rut360,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ramips_mt76x8_DEVICE_teltonika_rut361),tlt-rut361,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ath79_24kc_DEVICE_teltonika_tcr1xx),tlt-tcr1xx,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ath79_74kc_DEVICE_teltonika_rut9xx),tlt-rut9xx,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ath79_24kc_DEVICE_teltonika_rut2xx),tlt-rut2xx,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ramips_mt76x8_DEVICE_teltonika_rut2m),tlt-rut2m,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ramips_mt76x8_DEVICE_teltonika_tap100),tlt-tap100,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ramips_mt76x8_DEVICE_teltonika_otd140),tlt-otd140,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ramips_mt76x8_DEVICE_teltonika_rut9m),tlt-rut9m,)
else
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ath79_74kc_DEVICE_teltonika_rut9xx),tlt-rut9xx-vboot-64k,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ath79_74kc_DEVICE_teltonika_rut9xx),tlt-rut9xx-vboot,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ath79_74kc_DEVICE_teltonika_rut9xx),tlt-rut9xx,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ath79_24kc_DEVICE_teltonika_rut2xx),tlt-rut2xx-vboot-64k,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ath79_24kc_DEVICE_teltonika_rut2xx),tlt-rut2xx-vboot,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ath79_24kc_DEVICE_teltonika_rut2xx),tlt-rut2xx,)
	TARGET_DEVICE += $(if $(CONFIG_TARGET_ramips_mt76x8_DEVICE_teltonika_otd140),tlt-otd140,)
endif

define Build/Compile
	for d in $(TARGET_DEVICE); do \
		$(if $(CONFIG_BUILD_VERIFIED_BOOT_IMAGE), env -i PATH=$(OVERRIDE_PATH) \
			$(MAKE) -C $(PKG_BUILD_DIR) \
				BUILD_TOPDIR=$(PKG_BUILD_DIR) \
				CROSS_COMPILE=$(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS) \
					clean ; \
		) \
		env -i PATH=$(OVERRIDE_PATH) \
			$(MAKE) -C $(PKG_BUILD_DIR) \
				BUILD_TOPDIR=$(PKG_BUILD_DIR) \
				CROSS_COMPILE=$(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS) \
					$$$${d} ; \
	done
endef

define Package/uboot-ath79/install
	for d in $(TARGET_DEVICE); do \
		filename=$$$$(basename $(PKG_BUILD_DIR)/bin/u-boot_$$$${d}_*.md5 | rev | cut -c 5- | rev); \
		$(CP) $(PKG_BUILD_DIR)/bin/$$$$filename.bin $(BIN_DIR)/u-boot_$$$${d}.bin ; \
		$(CP) $(PKG_BUILD_DIR)/bin/$$$${filename}_webui.bin $(BIN_DIR)/u-boot_$$$${d}_webui.bin ; \
	done; \
	$(CP) $(PKG_BUILD_DIR)/version $(BIN_DIR)/u-boot_version ;
endef

$(eval $(call BuildPackage,uboot-ath79))
