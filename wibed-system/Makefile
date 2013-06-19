#    Copyright (C) 2013 Universitat Politecnica de Barcelona (UPC)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=wibed-system
PKG_RELEASE:=1
#PKG_SOURCE_URL:=@SF/wibed-system
#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/wibed-system
  SECTION:=net
  CATEGORY:=Base system
  TITLE:=Basic system requirements for Wibed
  URL:=http://confine-project.eu
  DEPENDS:= \
	+usbutils +sfdisk +e2fsprogs +sysfsutils \
	\
	+kmod-usb-storage +kmod-usb-uhci +kmod-usb2 +kmod-usb-ohci +kmod-usb-core \
	\
	+kmod-dummy +kmod-fs-vfat +kmod-fs-ext4

endef

define optional

endef

define Package/wibed-system/description
	minimal system requirements for Wibed
endef

define Package/wibed-system/conffiles

endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/wibed-system/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/usr
	$(INSTALL_DIR) $(1)/usr/sbin

	$(INSTALL_BIN) ./files/usr/sbin/wibed.prepare-usb $(1)/usr/sbin/

	$(CP) ./files/etc/uci-defaults/try_prepare_usb.sh $(1)/etc/uci-defaults/
	$(CP) ./files/etc/config/fstab $(1)/etc/config/
endef


$(eval $(call BuildPackage,wibed-system))

