#
# MIPS 74Kc Devices
#

define Device/ar9344
	SOC := ar9344
endef

define Device/teltonika_rut9xx
	$(Device/LegacyRUT)
	$(Device/ar9344)
	DEVICE_MODEL := RUT9XX
	DEVICE_FEATURES += usb-port gps serial serial-reset-quirk modbus port-mirror io wifi dualsim verified_boot bacnet ntrip
	TLT_LEGACY_MODEL := RUT9
	UBOOT_NAME := tlt-rut9xx
	TPLINK_HWID := 0x35000001

	# Default common packages for RUT9XX series
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Essential must-have:
	DEVICE_PACKAGES := kmod-spi-gpio kmod-mmc-spi kmod-i2c-gpio \
			   kmod-hwmon-mcp3021 kmod-hwmon-tla2021 kmod-cypress-serial

	# USB related:
	DEVICE_PACKAGES += kmod-usb2

	# Wireless related:
	DEVICE_PACKAGES += kmod-ath9k
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
endef
TARGET_DEVICES += teltonika_rut9xx
