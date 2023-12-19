#
# MIPS 24Kc Devices
#
include $(INCLUDE_DIR)/hardware.mk

define Device/qca9531
	SOC := qca9531
endef

define Device/ar9330
	SOC := ar9330
endef

define Device/teltonika_rut2xx
	$(Device/LegacyRUT)
	$(Device/ar9330)
	DEVICE_MODEL := RUT2XX
	DEVICE_BOOT_NAME := tlt-rut2xx tlt-rut2xx-vboot tlt-rut2xx-vboot-64k
	DEVICE_FEATURES += io wifi verified_boot high-watchdog-priority 64mb_ram mobile
	DEVICE_COMPAT_CODE := "RUT240.*"
	TLT_LEGACY_MODEL := RUT2
	TPLINK_HWID := 0x32200002

	# Default common packages for RUT2XX series
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# USB related:
	DEVICE_PACKAGES += kmod-usb-chipidea2

	# Wireless related:
	DEVICE_PACKAGES += kmod-ath9k_54
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	# Static board information
	HARDWARE/Ethernet/Port := 2
	HARDWARE/Ethernet/Speed := $(HW_ETH_SPEED_100)
	HARDWARE/Ethernet/Standard := $(HW_ETH_STD_80211) $(HW_ETH_STD_80211U) $(HW_ETH_STD_AUTO_MDI_MDIX)
	HARDWARE/Ethernet/WAN/Port := 1
	HARDWARE/Ethernet/LAN/Port := 1
endef
TARGET_DEVICES += teltonika_rut2xx

define Device/teltonika_trb2xx
	$(Device/qca9531)
	DEVICE_MODEL := TRB2XX
	DEVICE_BOOT_NAME := tlt-trb24x
	DEVICE_FEATURES += gateway gps serial serial-reset-quirk modbus io \
			single-port dualsim bacnet ntrip mobile 64mb_ram
	NO_ART := 1
	# Default common packages for TRB2XX series
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Essential must-have:
	DEVICE_PACKAGES := kmod-spi-gpio

	# USB related:
	DEVICE_PACKAGES += kmod-usb2 kmod-cypress-serial kmod-usb-serial-pl2303 \
			   kmod-usb-serial-ftdi
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
endef
TARGET_DEVICES += teltonika_trb2xx

define Device/teltonika_rut30x
	$(Device/qca9531)
	DEVICE_MODEL := RUT30X
	DEVICE_BOOT_NAME := tlt-rut300
	DEVICE_FEATURES += usb-port serial io port-mirror basic-router 64mb_ram ledman-lite
	NO_ART := 1
	# Default common packages for RUT30X series
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# USB related:
	DEVICE_PACKAGES += kmod-usb2
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
endef
TARGET_DEVICES += teltonika_rut30x

define Device/teltonika_rut36x
	$(Device/qca9531)
	DEVICE_MODEL := RUT36X
	DEVICE_BOOT_NAME := tlt-rut360
	DEVICE_FEATURES += io wifi mobile
	# Default common packages for RUT36X series
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Essential must-have:
	DEVICE_PACKAGES := kmod-spi-gpio

	# USB related:
	DEVICE_PACKAGES += kmod-usb2

	# Wireless related:
	DEVICE_PACKAGES += kmod-ath9k_54
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
endef
TARGET_DEVICES += teltonika_rut36x

define Device/teltonika_tcr1xx
	$(Device/qca9531)
	DEVICE_MODEL := TCR1XX
	DEVICE_BOOT_NAME := tlt-tcr1xx
	DEVICE_FEATURES += wifi guest-wifi rfkill wps mobile
	# Default common packages for TCR1XX series
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Essential must-have:
	DEVICE_PACKAGES := kmod-spi-gpio

	# USB related:
	DEVICE_PACKAGES += kmod-usb2

	# Wireless related:
	DEVICE_PACKAGES += kmod-ath9k_54 kmod-ath10k_54 ath10k-firmware-qca9887
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
endef
TARGET_DEVICES += teltonika_tcr1xx
