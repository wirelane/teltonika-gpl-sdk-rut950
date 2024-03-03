include $(TOPDIR)/rules.mk

APP_TITLE:=VuCI UI Support for I/O

CUSTOM_INSTALL=1
include ../app.mk


define Package/$(PKG_NAME)/install
	$(call Package/$(PKG_NAME)/install/Default,$(1))
	if [ $(TLT_PLATFORM_TRB1) ]; then \
		$(INSTALL_DIR) $(1)/www/tlt-icons ; \
		$(CP) ./pinout-icons/io_16pin.svg $(1)/www/tlt-icons/; \
		gzip -f $(1)/www/tlt-icons/io_16pin.svg; \
	elif [ $(TLT_PLATFORM_TRB2) ] || [ $(TLT_PLATFORM_TRB2M) ]; then \
		$(INSTALL_DIR) $(1)/www/tlt-icons ; \
		$(CP) ./pinout-icons/io_16pin_rs.svg $(1)/www/tlt-icons/; \
		gzip -f $(1)/www/tlt-icons/io_16pin_rs.svg; \
	elif [ $(TLT_PLATFORM_RUT9) ] || [ $(TLT_PLATFORM_RUT9M) ]; then \
		$(INSTALL_DIR) $(1)/www/tlt-icons ; \
		$(CP) ./pinout-icons/io_10pin.svg $(1)/www/tlt-icons/; \
		gzip -f $(1)/www/tlt-icons/io_10pin.svg; \
	fi;
endef

# call BuildPackage - OpenWrt buildroot signature
$(eval $(call BuildPackage,$(PKG_NAME)))
