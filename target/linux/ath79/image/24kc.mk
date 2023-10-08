#
# MIPS 24Kc Devices
#

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
	DEVICE_FEATURES += io wifi verified_boot high-watchdog-priority 64mb_ram
	DEVICE_COMPAT_CODE := "RUT240.*"
	TLT_LEGACY_MODEL := RUT2
	UBOOT_NAME := tlt-rut2xx
	TPLINK_HWID := 0x32200002

	# Default common packages for RUT2XX series
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# USB related:
	DEVICE_PACKAGES += kmod-usb-chipidea2

	# Wireless related:
	DEVICE_PACKAGES += kmod-ath9k
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
endef
TARGET_DEVICES += teltonika_rut2xx

define Device/teltonika_trb2xx
	$(Device/qca9531)
	DEVICE_MODEL := TRB2XX
	DEVICE_FEATURES += gateway gps serial serial-reset-quirk modbus io single-port dualsim bacnet ntrip 64mb_ram
	UBOOT_NAME := tlt-trb24x
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

define Device/teltonika_otd1xx
	$(Device/qca9531)
	DEVICE_MODEL := OTD1XX
	DEVICE_FEATURES += wifi dualsim
	UBOOT_NAME := tlt-otd1xx
	# Default common packages for OTD1XX series
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Essential must-have:
	DEVICE_PACKAGES := kmod-spi-gpio

	# USB related:
	DEVICE_PACKAGES += kmod-usb2

	# Wireless related:
	DEVICE_PACKAGES += kmod-ath9k kmod-ath10k ath10k-firmware-qca9887
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
endef
TARGET_DEVICES += teltonika_otd1xx

define Device/teltonika_rut30x
	$(Device/qca9531)
	DEVICE_MODEL := RUT30X
	DEVICE_FEATURES += usb-port serial io port-mirror basic-router 64mb_ram
	UBOOT_NAME := tlt-rut300
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
	DEVICE_FEATURES += io wifi
	UBOOT_NAME := tlt-rut360
	# Default common packages for RUT36X series
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Essential must-have:
	DEVICE_PACKAGES := kmod-spi-gpio

	# USB related:
	DEVICE_PACKAGES += kmod-usb2

	# Wireless related:
	DEVICE_PACKAGES += kmod-ath9k
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
endef
TARGET_DEVICES += teltonika_rut36x

define Device/teltonika_tcr1xx
	$(Device/qca9531)
	DEVICE_MODEL := TCR1XX
	DEVICE_FEATURES += wifi guest-wifi rfkill wps
	UBOOT_NAME := tlt-tcr1xx
	# Default common packages for TCR1XX series
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# Essential must-have:
	DEVICE_PACKAGES := kmod-spi-gpio

	# USB related:
	DEVICE_PACKAGES += kmod-usb2

	# Wireless related:
	DEVICE_PACKAGES += kmod-ath9k kmod-ath10k ath10k-firmware-qca9887
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
endef
TARGET_DEVICES += teltonika_tcr1xx
