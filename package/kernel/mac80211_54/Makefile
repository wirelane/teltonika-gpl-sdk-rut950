#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mac80211_54

PKG_VERSION:=5.10.68-1
PKG_RELEASE:=1
PKG_SOURCE_URL:=@KERNEL/linux/kernel/projects/backports/stable/v5.10.68/
PKG_HASH:=bba161b0084590c677a84b80993709e388a3c478f29ed0c475d4fce1b9162968

PKG_SOURCE:=backports-$(PKG_VERSION).tar.xz
PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/backports-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>

PKG_DRIVERS = \
	adm8211_54 \
	airo_54 \
	hermes_54 hermes-pci_54 hermes-pcmcia_54 hermes-plx_54\
	lib80211_54 \
	mac80211-hwsim_54 \
	mt7601u_54 \
	p54-common_54 p54-pci_54 p54-usb_54 \
	rsi91x_54 rsi91x-usb_54 rsi91x-sdio_54\
	wlcore_54 wl12xx_54 wl18xx_54 \
	zd1211rw_54

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_kmod-mac80211_54 \
	CONFIG_PACKAGE_CFG80211_TESTMODE \
	CONFIG_PACKAGE_MAC80211_DEBUGFS \
	CONFIG_PACKAGE_MAC80211_MESH \
	CONFIG_PACKAGE_MAC80211_TRACING \
	CONFIG_PACKAGE_IWLWIFI_DEBUG \
	CONFIG_PACKAGE_IWLWIFI_DEBUGFS \
	CONFIG_PACKAGE_RTLWIFI_DEBUG \

include $(INCLUDE_DIR)/package.mk

WMENU:=Wireless Drivers

define KernelPackage/mac80211_54/Default
  SUBMENU:=$(WMENU)
  URL:=https://wireless.wiki.kernel.org/
  MAINTAINER:=Felix Fietkau <nbd@nbd.name>
endef

config_package=$(if $(CONFIG_PACKAGE_kmod-$(1)),m)

config-y:= \
	WLAN \
	CFG80211_WEXT \
	CFG80211_CERTIFICATION_ONUS \
	MAC80211_RC_MINSTREL \
	MAC80211_RC_MINSTREL_HT \
	MAC80211_RC_MINSTREL_VHT \
	MAC80211_RC_DEFAULT_MINSTREL \
	WLAN_VENDOR_ADMTEK \
	WLAN_VENDOR_ATH \
	WLAN_VENDOR_ATMEL \
	WLAN_VENDOR_BROADCOM \
	WLAN_VENDOR_CISCO \
	WLAN_VENDOR_INTEL \
	WLAN_VENDOR_INTERSIL \
	WLAN_VENDOR_MARVELL \
	WLAN_VENDOR_MEDIATEK \
	WLAN_VENDOR_RALINK \
	WLAN_VENDOR_REALTEK \
	WLAN_VENDOR_RSI \
	WLAN_VENDOR_ST \
	WLAN_VENDOR_TI \
	WLAN_VENDOR_ZYDAS \

config-$(call config_package,cfg80211_54) += CFG80211
config-$(CONFIG_PACKAGE_CFG80211_TESTMODE) += NL80211_TESTMODE

config-$(call config_package,mac80211_54) += MAC80211
config-$(CONFIG_PACKAGE_MAC80211_MESH) += MAC80211_MESH

include ath.mk
include ralink.mk

PKG_CONFIG_DEPENDS += \
	$(patsubst %,CONFIG_PACKAGE_kmod-%,$(PKG_DRIVERS))

define KernelPackage/cfg80211_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=cfg80211 - wireless configuration API
  DEPENDS+= +iw +wireless-regdb
  ABI_VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
  FILES:= \
	$(PKG_BUILD_DIR)/compat/compat.ko \
	$(PKG_BUILD_DIR)/net/wireless/cfg80211.ko
  ifneq ($(CONFIG_USES_VENDOR_WIFI_DRIVER),)
	AUTOLOAD:=$(call AutoProbe,cfg80211)
  endif
  CONFLICTS:=kmod-cfg80211
endef

define KernelPackage/cfg80211_54/description
cfg80211 is the Linux wireless LAN (802.11) configuration API.
endef

define KernelPackage/cfg80211_54/config
  if PACKAGE_kmod-cfg80211_54

	config PACKAGE_CFG80211_TESTMODE
		bool "Enable testmode command support"
		default n
		help
		  This is typically used for tests and calibration during
		  manufacturing, or vendor specific debugging features

  endif
endef


define KernelPackage/mac80211_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=Linux 802.11 Wireless Networking Stack
  # +kmod-crypto-cmac is a runtime only dependency of net/mac80211/aes_cmac.c
  DEPENDS+= +kmod-cfg80211_54 +hostapd-common
  KCONFIG:=\
	CONFIG_AVERAGE=y
  FILES:= $(PKG_BUILD_DIR)/net/mac80211/mac80211.ko
  ABI_VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
  CONFLICTS:=kmod-mac80211
  MENU:=1
endef

define KernelPackage/mac80211_54/config
  if PACKAGE_kmod-mac80211_54

	config PACKAGE_MAC80211_DEBUGFS
		bool "Export mac80211 internals in DebugFS"
		select KERNEL_DEBUG_FS
		default y
		help
		  Select this to see extensive information about
		  the internal state of mac80211 in debugfs.

	config PACKAGE_MAC80211_TRACING
		bool "Enable tracing (mac80211 and supported drivers)"
		select KERNEL_FTRACE
		select KERNEL_ENABLE_DEFAULT_TRACERS
		default n
		help
		  Select this to enable tracing of mac80211 and
		  related wifi drivers (using trace-cmd).

	config PACKAGE_MAC80211_MESH
		bool "Enable 802.11s mesh support"
		default y

  endif
endef

define KernelPackage/mac80211_54/description
Generic IEEE 802.11 Networking Stack (mac80211)
endef

define KernelPackage/adm8211_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=ADMTek 8211 support
  DEPENDS+=@PCI_SUPPORT +kmod-mac80211_54 +kmod-eeprom-93cx6
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/admtek/adm8211.ko
  CONFLICTS:=kmod-adm8211
  AUTOLOAD:=$(call AutoProbe,adm8211)
endef

define KernelPackage/airo_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=Cisco Aironet driver
  DEPENDS+=@PCI_SUPPORT +@DRIVER_WEXT_SUPPORT +kmod-cfg80211_54 @TARGET_x86 @BROKEN
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/cisco/airo.ko
  CONFLICTS:=kmod-airo
  AUTOLOAD:=$(call AutoProbe,airo)
endef

define KernelPackage/airo_54/description
 Kernel support for Cisco Aironet cards
endef

define KernelPackage/hermes_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=Hermes 802.11b chipset support
  DEPENDS:=@PCI_SUPPORT||PCMCIA_SUPPORT +kmod-cfg80211_54 +@DRIVER_WEXT_SUPPORT +kmod-crypto-michael-mic
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/intersil/orinoco/orinoco.ko
  CONFLICTS:=kmod-hermes
  AUTOLOAD:=$(call AutoProbe,orinoco)
endef

define KernelPackage/hermes_54/description
 Kernel support for Hermes 802.11b chipsets
endef

define KernelPackage/hermes-pci_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=Intersil Prism 2.5 PCI support
  DEPENDS:=@PCI_SUPPORT +kmod-hermes_54
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/intersil/orinoco/orinoco_pci.ko
  CONFLICTS:=kmod-hermes-pci
  AUTOLOAD:=$(call AutoProbe,orinoco_pci)
endef

define KernelPackage/hermes-pci_54/description
 Kernel modules for Intersil Prism 2.5 PCI support
endef

define KernelPackage/hermes-plx_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=PLX9052 based PCI adaptor
  DEPENDS:=@PCI_SUPPORT +kmod-hermes_54
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/intersil/orinoco/orinoco_plx.ko
  CONFLICTS:=kmod-hermes-plx
  AUTOLOAD:=$(call AutoProbe,orinoco_plx)
endef

define KernelPackage/hermes-plx_54/description
 Kernel modules for Hermes in PLX9052 based PCI adaptors
endef

define KernelPackage/hermes-pcmcia_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=Hermes based PCMCIA adaptors
  DEPENDS:=@PCMCIA_SUPPORT +kmod-hermes_54 +kmod-pcmcia-core
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/intersil/orinoco/orinoco_cs.ko
  CONFLICTS:=kmod-hermes-pcmcia
  AUTOLOAD:=$(call AutoProbe,orinoco_cs)
endef

define KernelPackage/hermes-pcmcia_54/description
 Kernel modules for Hermes based PCMCIA adaptors
endef


define KernelPackage/lib80211_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=802.11 Networking stack
  DEPENDS:=+kmod-cfg80211_54 +kmod-crypto-hash +kmod-crypto-ccm
  FILES:= \
	$(PKG_BUILD_DIR)/net/wireless/lib80211.ko \
	$(PKG_BUILD_DIR)/net/wireless/lib80211_crypt_wep.ko \
	$(PKG_BUILD_DIR)/net/wireless/lib80211_crypt_ccmp.ko \
	$(PKG_BUILD_DIR)/net/wireless/lib80211_crypt_tkip.ko
  CONFLICTS:=kmod-lib80211
  AUTOLOAD:=$(call AutoProbe, \
	lib80211 \
	lib80211_crypt_wep \
	lib80211_crypt_ccmp \
	lib80211_crypt_tkip \
  )
endef

define KernelPackage/lib80211_54/description
 Kernel modules for 802.11 Networking stack
 Includes:
 - lib80211
 - lib80211_crypt_wep
 - lib80211_crypt_tkip
 - lib80211_crytp_ccmp
endef


define KernelPackage/mac80211-hwsim_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=mac80211 HW simulation device
  DEPENDS+= +kmod-mac80211_54 +@DRIVER_11AC_SUPPORT +@DRIVER_11N_SUPPORT
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/mac80211_hwsim.ko
  CONFLICTS:=kmod-mac80211-hwsim
  AUTOLOAD:=$(call AutoProbe,mac80211_hwsim)
endef


define KernelPackage/mt7601u_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=MT7601U-based USB dongles Wireless Driver
  DEPENDS+= +kmod-mac80211_54 +@DRIVER_11N_SUPPORT @USB_SUPPORT +kmod-usb-core +mt7601u-firmware
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/mediatek/mt7601u/mt7601u.ko
  CONFLICTS:=kmod-mt7601u
  AUTOLOAD:=$(call AutoProbe,mt7601u)
endef

define KernelPackage/p54_54/Default
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=Prism54 Drivers
endef

define KernelPackage/p54_54/description
  Kernel module for Prism54 chipsets (mac80211)
endef

define KernelPackage/p54-common_54
  $(call KernelPackage/p54_54/Default)
  DEPENDS+= @(PCI_SUPPORT||USB_SUPPORT) +kmod-mac80211_54 +kmod-lib-crc-ccitt
  TITLE+= (COMMON)
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/intersil/p54/p54common.ko
  CONFLICTS:=kmod-p54-common
endef

define KernelPackage/p54-pci_54
  $(call KernelPackage/p54_54/Default)
  TITLE+= (PCI)
  DEPENDS+= @PCI_SUPPORT +kmod-p54-common_54
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/intersil/p54/p54pci.ko
  CONFLICTS:=kmod-p54-pci
  AUTOLOAD:=$(call AutoProbe,p54pci)
endef

define KernelPackage/p54-usb_54
  $(call KernelPackage/p54_54/Default)
  TITLE+= (USB)
  DEPENDS+= @USB_SUPPORT +kmod-usb-core +kmod-p54-common_54
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/intersil/p54/p54usb.ko
  CONFLICTS:=kmod-p54-usb
  AUTOLOAD:=$(call AutoProbe,p54usb)
endef

define KernelPackage/rsi91x_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=Redpine Signals Inc 91x WLAN driver support
  DEPENDS+= +kmod-mac80211_54 +rs9113-firmware +@DRIVER_11N_SUPPORT
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/rsi/rsi_91x.ko
  CONFLICTS:=kmod-rsi91x
endef

define KernelPackage/rsi91x-usb_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=Redpine Signals USB bus support
  DEPENDS+=@USB_SUPPORT +kmod-usb-core +kmod-mac80211_54 +kmod-rsi91x +rs9113-firmware
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/rsi/rsi_usb.ko
  CONFLICTS:=kmod-rsi91x-usb
  AUTOLOAD:=$(call AutoProbe,rsi_usb)
endef

define KernelPackage/rsi91x-sdio_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=Redpine Signals SDIO bus support
  DEPENDS+= +kmod-mac80211_54 +kmod-mmc +kmod-rsi91x_54 +rs9113-firmware
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/rsi/rsi_sdio.ko
  CONFLICTS:=kmod-rsi91x-sdio
  AUTOLOAD:=$(call AutoProbe,rsi_sdio)
endef


define KernelPackage/wlcore_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=TI common driver part
  DEPENDS+= +kmod-mmc +kmod-mac80211_54 +@DRIVER_11N_SUPPORT
  FILES:= \
	$(PKG_BUILD_DIR)/drivers/net/wireless/ti/wlcore/wlcore.ko \
	$(PKG_BUILD_DIR)/drivers/net/wireless/ti/wlcore/wlcore_sdio.ko
  AUTOLOAD:=$(call AutoProbe,wlcore wlcore_sdio)
endef

define KernelPackage/wlcore_54/description
 This module contains some common parts needed by TI Wireless drivers.
endef

define KernelPackage/wl12xx_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=Driver for TI WL12xx
  URL:=https://wireless.wiki.kernel.org/en/users/drivers/wl12xx
  DEPENDS+= +kmod-wlcore +wl12xx-firmware
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/ti/wl12xx/wl12xx.ko
  CONFLICTS:=kmod-wl12xx
  AUTOLOAD:=$(call AutoProbe,wl12xx)
endef

define KernelPackage/wl12xx_54/description
 Kernel modules for TI WL12xx
endef

define KernelPackage/wl18xx_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=Driver for TI WL18xx_54
  URL:=https://wireless.wiki.kernel.org/en/users/drivers/wl18xx
  DEPENDS+= +kmod-wlcore_54 +wl18xx-firmware
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/ti/wl18xx/wl18xx.ko
  AUTOLOAD:=$(call AutoProbe,wl18xx)
endef

define KernelPackage/wl18xx_54/description
 Kernel modules for TI WL18xx_54
endef


ZD1211FW_NAME:=zd1211-firmware
ZD1211FW_VERSION:=1.4
define Download/zd1211rw_54
  FILE:=$(ZD1211FW_NAME)-$(ZD1211FW_VERSION).tar.bz2
  URL:=@SF/zd1211/
  HASH:=866308f6f59f7075f075d4959dff2ede47735c751251fecd1496df1ba4d338e1
endef
$(eval $(call Download,zd1211rw_54))

define KernelPackage/zd1211rw_54
  $(call KernelPackage/mac80211_54/Default)
  TITLE:=Zydas ZD1211 support
  DEPENDS+= @USB_SUPPORT +kmod-usb-core +kmod-mac80211_54
  FILES:=$(PKG_BUILD_DIR)/drivers/net/wireless/zydas/zd1211rw/zd1211rw.ko
  CONFLICTS:=kmod-zd1211rw
  AUTOLOAD:=$(call AutoProbe,zd1211rw)
endef

ifdef CONFIG_PACKAGE_MAC80211_DEBUGFS
  config-y += \
	CFG80211_DEBUGFS \
	MAC80211_DEBUGFS
endif

ifdef CONFIG_PACKAGE_MAC80211_TRACING
  config-y += \
	IWLWIFI_DEVICE_TRACING
endif

config-$(call config_package,lib80211_54) += LIB80211 LIB80211_CRYPT_WEP LIB80211_CRYPT_CCMP LIB80211_CRYPT_TKIP

config-$(call config_package,airo_54) += AIRO

config-$(call config_package,mac80211-hwsim_54) += MAC80211_HWSIM
config-$(call config_package,mt7601u_54) += MT7601U
config-y += WL_MEDIATEK

config-$(call config_package,p54-common_54) += P54_COMMON
config-$(call config_package,p54-pci_54) += P54_PCI
config-$(call config_package,p54-usb_54) += P54_USB

config-$(call config_package,hermes_54) += HERMES
config-$(call config_package,hermes-pci_54) += PCI_HERMES
config-$(call config_package,hermes-plx_54) += PLX_HERMES
config-$(call config_package,hermes-pcmcia_54) += PCMCIA_HERMES
config-y += HERMES_PRISM

config-$(call config_package,adm8211_54) += ADM8211
config-$(call config_package,wlcore_54) += WLCORE WLCORE_SDIO
config-$(call config_package,wl12xx_54) += WL12XX
config-$(call config_package,wl18xx_54) += WL18XX
config-y += WL_TI WILINK_PLATFORM_DATA
config-$(call config_package,zd1211rw_54) += ZD1211RW
config-$(call config_package,rsi91x_54) += RSI_91X
config-$(call config_package,rsi91x-usb_54) += RSI_USB
config-$(call config_package,rsi91x-sdio_54) += RSI_SDIO

config-$(CONFIG_LEDS_TRIGGERS) += MAC80211_LEDS

MAKE_OPTS:= -C "$(PKG_BUILD_DIR)" \
	$(KERNEL_MAKE_FLAGS) \
	EXTRA_CFLAGS="-I$(PKG_BUILD_DIR)/include $(IREMAP_CFLAGS)" \
	KLIB_BUILD="$(LINUX_DIR)" \
	MODPROBE=true \
	KLIB=$(TARGET_MODULES_DIR) \
	KERNEL_SUBLEVEL=$(lastword $(subst ., ,$(KERNEL_PATCHVER))) \
	KBUILD_LDFLAGS_MODULE_PREREQ=

define ConfigVars
$(subst $(space),,$(foreach opt,$(config-$(1)),CPTCFG_$(opt)=$(1)
))
endef

define mac80211_config_54
$(call ConfigVars,m)$(call ConfigVars,y)
endef
$(eval $(call shexport,mac80211_config_54))

define Build/Prepare
	rm -rf $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)
	$(PKG_UNPACK)
	$(Build/Patch)
	$(TAR) -C $(PKG_BUILD_DIR) -xjf $(DL_DIR)/$(ZD1211FW_NAME)-$(ZD1211FW_VERSION).tar.bz2
	rm -rf \
		$(PKG_BUILD_DIR)/include/linux/ssb \
		$(PKG_BUILD_DIR)/include/linux/bcma \
		$(PKG_BUILD_DIR)/include/net/bluetooth

	rm -f \
		$(PKG_BUILD_DIR)/include/linux/cordic.h \
		$(PKG_BUILD_DIR)/include/linux/crc8.h \
		$(PKG_BUILD_DIR)/include/linux/eeprom_93cx6.h \
		$(PKG_BUILD_DIR)/include/linux/wl12xx.h \
		$(PKG_BUILD_DIR)/include/linux/spi/libertas_spi.h \
		$(PKG_BUILD_DIR)/include/net/ieee80211.h \
		$(PKG_BUILD_DIR)/backport-include/linux/bcm47xx_nvram.h

	echo 'compat-wireless-$(PKG_VERSION)-$(PKG_RELEASE)-$(REVISION)' > $(PKG_BUILD_DIR)/compat_version
endef

ifneq ($(CONFIG_PACKAGE_kmod-cfg80211_54)$(CONFIG_PACKAGE_kmod-lib80211_54),)
 define Build/Compile/kmod
	rm -rf $(PKG_BUILD_DIR)/modules
	+$(MAKE) $(PKG_JOBS) $(MAKE_OPTS) modules
 endef
endif

#do not Build/Configure for EXTERNAL KERNEL
ifeq ($(strip $(CONFIG_EXTERNAL_KERNEL_TREE)),"")
  ifeq ($(strip $(CONFIG_KERNEL_GIT_CLONE_URI)),"")
    define Build/Configure
	  cmp $(PKG_BUILD_DIR)/include/linux/ath9k_platform.h $(LINUX_DIR)/include/linux/ath9k_platform.h
	  cmp $(PKG_BUILD_DIR)/include/linux/ath5k_platform.h $(LINUX_DIR)/include/linux/ath5k_platform.h
	  cmp $(PKG_BUILD_DIR)/include/linux/rt2x00_platform.h $(LINUX_DIR)/include/linux/rt2x00_platform.h
    endef
  endif
endif

define Build/Patch
	$(if $(QUILT),rm -rf $(PKG_BUILD_DIR)/patches; mkdir -p $(PKG_BUILD_DIR)/patches)
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/build,build/)
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/subsys,subsys/)
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/ath,ath/)
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/rt2x00,rt2x00/)
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/mwl,mwl/)
	$(call PatchDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/brcm,brcm/)
	$(if $(QUILT),touch $(PKG_BUILD_DIR)/.quilt_used)
endef

define Quilt/Refresh/Package
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/build,build/)
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/subsys,subsys/)
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/ath,ath/)
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/rt2x00,rt2x00/)
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/mwl,mwl/)
	$(call Quilt/RefreshDir,$(PKG_BUILD_DIR),$(PATCH_DIR)/brcm,brcm/)
endef

define Build/Compile
	$(SH_FUNC) var2file "$(call shvar,mac80211_config_54)" $(PKG_BUILD_DIR)/.config
	$(MAKE) $(MAKE_OPTS) allnoconfig
	$(call Build/Compile/kmod)
endef

define Build/InstallDev
	mkdir -p \
		$(1)/usr/include/mac80211 \
		$(1)/usr/include/mac80211-backport \
		$(1)/usr/include/mac80211/ath \
		$(1)/usr/include/net/mac80211
	$(CP) $(PKG_BUILD_DIR)/net/mac80211/*.h $(PKG_BUILD_DIR)/include/* $(1)/usr/include/mac80211/
	$(CP) $(PKG_BUILD_DIR)/backport-include/* $(1)/usr/include/mac80211-backport/
	$(CP) $(PKG_BUILD_DIR)/net/mac80211/rate.h $(1)/usr/include/net/mac80211/
	$(CP) $(PKG_BUILD_DIR)/drivers/net/wireless/ath/*.h $(1)/usr/include/mac80211/ath/
	rm -f $(1)/usr/include/mac80211-backport/linux/module.h
endef

ifeq ($(CONFIG_USES_VENDOR_WIFI_DRIVER),)
define KernelPackage/cfg80211_54/install
	$(INSTALL_DIR) $(1)/lib/wifi $(1)/lib/netifd/wireless
	$(INSTALL_DATA) ./files/lib/wifi/mac80211.sh $(1)/lib/wifi
	$(INSTALL_DATA) ./files/lib/netifd/mac80211.sh $(1)/lib/netifd
	$(INSTALL_BIN) ./files/lib/netifd/wireless/mac80211.sh $(1)/lib/netifd/wireless
	$(INSTALL_DIR) $(1)/etc/hotplug.d/ieee80211
	$(INSTALL_DATA) ./files/mac80211.hotplug $(1)/etc/hotplug.d/ieee80211/10-wifi-detect
endef
endif

define KernelPackage/zd1211rw_54/install
	$(INSTALL_DIR) $(1)/lib/firmware/zd1211
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/$(ZD1211FW_NAME)/zd1211* $(1)/lib/firmware/zd1211
endef

$(eval $(foreach drv,$(PKG_DRIVERS),$(call KernelPackage,$(drv))))
$(eval $(call KernelPackage,cfg80211_54))
$(eval $(call KernelPackage,mac80211_54))
