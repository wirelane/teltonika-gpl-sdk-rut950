include $(TOPDIR)/rules.mk

ARCH:=mips
BOARD:=ath79
BOARDNAME:=Atheros ATH79
SUBTARGETS:=24kc 74kc

FEATURES:=squashfs

KERNEL_PATCHVER:=5.4

include $(INCLUDE_DIR)/target.mk
include $(INCLUDE_DIR)/target-gpl.mk

DEFAULT_PACKAGES += swconfig tc-tiny

$(eval $(call BuildTarget))
