include $(TOPDIR)/rules.mk
#include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=lua-curl
PKG_VERSION:=2013-15-12.1
PKG_RELEASE=$(PKG_SOURCE_VERSION)-1

#PKG_SOURCE_PROTO:=git
#PKG_SOURCE_URL:=git://github.com/msva/lua-curl
#PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
#PKG_SOURCE_VERSION:=7bbb9ebfd4aa72a03b8fff51b3436b0d39fbcf7f
#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
CMAKE_INSTALL:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

PKG_MAINTAINER:=Manos <manos@manos.org>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk


define Package/lua-curl
  SECTION:=base
  CATEGORY:=Utils
  DEPENDS:=+lua +libcurl
  TITLE:=Lua-curl
endef


define Package/description
	Lua-curl lib
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

#define Build/Configure
#endef

#define Build/Compile
#	$(MAKE)
#endef

define Package/lua-curl/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(CP) $(PKG_BUILD_DIR)/cURL.so $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,lua-curl))
