#
# Copyright (C) 2023 Teltonika
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lrexlib
PKG_VERSION:=2021-12-28
GPL_INCLUDE_SRC:=1

PKG_ORIGIN_URL:=https://github.com/rrthomas/lrexlib
# PKG_SOURCE_VERSION:=870a0d5a664565b5ee0a6b9edb8ebd44b0d20a8c

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/lrexlib
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=A library for exposing regex functions to LUA.
	DEPENDS:=+liblua +lua +libc
endef

define Package/lrexlib/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rex_posix.so $(1)/usr/lib/lua
endef

$(eval $(call BuildPackage,lrexlib))
