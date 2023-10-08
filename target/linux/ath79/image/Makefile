include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

KERNEL_LOADADDR = 0x80060000

DEVICE_VARS += LOADER_FLASH_OFFS LOADER_TYPE
DEVICE_VARS += LOADER_FLASH_MAX LOADER_KERNEL_MAGIC

DEVICE_VARS += TPLINK_HWID TPLINK_HWREV TPLINK_FLASHLAYOUT TPLINK_HEADER_VERSION
DEVICE_VARS += UBOOT_NAME UBOOT_SIZE
DEVICE_VARS += CONFIG_SIZE
DEVICE_VARS += ART_SIZE NO_ART
DEVICE_VARS += MASTER_IMAGE_SIZE
DEVICE_VARS += TLT_LEGACY_MODEL
DEVICE_VARS += SIGNATURE_SIZE
DEVICE_VARS += SYSUPGRADE_OFFSET

define rootfs_align
$(patsubst %-256k,0x40000,$(patsubst %-128k,0x20000,$(patsubst %-64k,0x10000,$(patsubst squashfs%,0x4,$(patsubst root.%,%,$(1))))))
endef

define Build/append-tlt-uboot
  dd if="$(BIN_DIR)/u-boot_$(UBOOT_NAME)$(word 1,$(1)).bin" >> $@
endef

define Build/append-tlt-config
  dd if=$(TOPDIR)/target/linux/ath79/image/bin/tlt-factory-config.bin >> $@
endef

define Build/append-tlt-art
  if [ $(NO_ART) == 1 ]; then \
    dd if=/dev/zero bs=$(ART_SIZE) count=1 >> $@; \
  elif [ "$(DEVICE_MODEL)" == "RUT2XX" ]; then \
    dd if=$(TOPDIR)/target/linux/ath79/image/bin/tlt-factory-art-RUT2XX.bin >> $@; \
  elif [ "$(DEVICE_MODEL)" == "TCR1XX" ]; then \
    dd if=$(TOPDIR)/target/linux/ath79/image/bin/tlt-factory-art-TCR1XX.bin >> $@; \
  else \
    dd if=$(TOPDIR)/target/linux/ath79/image/bin/tlt-factory-art.bin >> $@; \
  fi
endef

define Build/mktltfw
  # If building master image, temporarily remove everything up to sysupgrade image start
  $(if $(findstring master,$(word 2,$(1))), \
  cp $@ $@.start; dd if=$@ of=$@.fw skip=1 bs=$(SYSUPGRADE_OFFSET) && mv $@.fw $@)

  -$(STAGING_DIR_HOST)/bin/mktplinkfw \
    -H $(TPLINK_HWID) -W $(TPLINK_HWREV) -F $(TPLINK_FLASHLAYOUT) -N Teltonika \
    -V $(TLT_LEGACY_MODEL)xx \
    -m $(TPLINK_HEADER_VERSION) \
    -k $(IMAGE_KERNEL) \
    -r $@ \
    -o $@.new \
    -j -X 0x40000 \
    -a $(call rootfs_align,$(FILESYSTEM)) \
    $(wordlist 2,$(words $(1)),$(1)) \
    $(if $(findstring sysupgrade,$(word 1,$(1))),-s) && mv $@.new $@ || rm -f $@

  # If building master image, add processed image to master firmware image
  $(if $(findstring master,$(word 2,$(1))), \
  dd if=$@ of=$@.start seek=1 bs=$(SYSUPGRADE_OFFSET) && mv $@.start $@)
endef

define Device/Default
  DEVICE_VENDOR := TELTONIKA
  DEVICE_DTS_DIR := ../dts
  DEVICE_DTS = $$(SOC)_$(1)
  DEVICE_FEATURES := small_flash sw-offload
  PROFILES = Default
  MTDPARTS :=
  BLOCKSIZE := 64k
  KERNEL := kernel-bin | append-dtb | lzma | uImage lzma
  KERNEL_INITRAMFS := kernel-bin | append-dtb | lzma | uImage lzma
  LOADER_KERNEL_MAGIC :=
  LOADER_FLASH_MAX :=
  LOADER_FLASH_OFFS :=
  LOADER_TYPE :=
  COMPILE :=
  UBOOT_NAME :=
  UBOOT_SIZE := 131072
  CONFIG_SIZE := 65536
  ART_SIZE := 65536
  NO_ART := 0
  IMAGE_SIZE := 15552k
  MASTER_IMAGE_SIZE := 16384k
  SIGNATURE_SIZE := 256
  SYSUPGRADE_OFFSET := 262144
  IMAGES := sysupgrade.bin \
            $(if $(CONFIG_BUILD_FACTORY_IMAGE),master_fw.bin)
  IMAGE/sysupgrade.bin = append-kernel | pad-to $$$$(BLOCKSIZE) | \
                         append-rootfs | pad-rootfs | append-metadata | \
                         check-size $$$$(IMAGE_SIZE) | finalize-tlt-webui
  IMAGE/master_fw.bin = append-tlt-uboot | pad-to $$$$(UBOOT_SIZE) | \
                        append-tlt-config | pad-to $$$$(CONFIG_SIZE) | \
                        append-tlt-art | pad-to $$$$(ART_SIZE) | \
                        append-kernel | pad-to $$$$(BLOCKSIZE) | \
                        append-rootfs | pad-rootfs | \
                        append-version | \
                        check-size $$$$(MASTER_IMAGE_SIZE) | \
                        finalize-tlt-master-stendui
  HW_MODS := mod1%ftdi_new
endef

define Device/LegacyRUT
  TPLINK_FLASHLAYOUT := 16Mlzma
  TPLINK_HWREV := 0x1
  TPLINK_HEADER_VERSION := 1
  LOADER_TYPE := gz
  KERNEL := kernel-bin | append-dtb | lzma
  KERNEL_INITRAMFS := kernel-bin | append-dtb | lzma | tplink-v1-header | \
                      append-signature
  IMAGES += $(if $(and $(CONFIG_BUILD_FACTORY_IMAGE),$(CONFIG_BUILD_VERIFIED_BOOT_IMAGE)),\
              master_fw_vboot.bin)
  IMAGE/sysupgrade.bin := append-rootfs | pad-extra $$$$(SIGNATURE_SIZE) | \
                          mktltfw sysupgrade | append-signature | \
                          append-metadata | finalize-tlt-webui
  IMAGE/master_fw.bin = append-tlt-uboot | pad-to $$$$(UBOOT_SIZE) | \
                        append-tlt-config | pad-to $$$$(CONFIG_SIZE) | \
                        append-tlt-art | pad-to $$$$(ART_SIZE) | \
                        append-rootfs | pad-extra $$$$(SIGNATURE_SIZE) | \
                        mktltfw sysupgrade master | append-signature master | \
                        append-version | \
                        check-size $$$$(MASTER_IMAGE_SIZE) | \
                        finalize-tlt-master-stendui
  IMAGE/master_fw_vboot.bin = append-tlt-uboot -vboot | pad-to $$$$(UBOOT_SIZE) | \
                              append-tlt-config | pad-to $$$$(CONFIG_SIZE) | \
                              append-tlt-art | pad-to $$$$(ART_SIZE) | \
                              append-rootfs | pad-extra $$$$(SIGNATURE_SIZE) | \
                              mktltfw sysupgrade master | append-signature master | \
                              append-version | \
                              check-size $$$$(MASTER_IMAGE_SIZE) | \
                              finalize-tlt-master-stendui -vboot
endef

include $(SUBTARGET).mk

$(eval $(call BuildImage))
