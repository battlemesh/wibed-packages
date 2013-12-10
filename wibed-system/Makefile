# Copyright (C) 2013 Universitat Politecnica de Catalunya (UPC)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=wibed-system
PKG_RELEASE:=4
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

TIMESTAMP := $(shell date -u +%Y%m%d-%H%M)
GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
GIT_HASH := $(shell git rev-parse HEAD)

include $(INCLUDE_DIR)/package.mk

define Package/wibed-system
  SECTION:=net
  CATEGORY:=Base system
  TITLE:=Basic system requirements for Wibed
  URL:=http://confine-project.eu
  DEPENDS:= \
	+usbutils +sfdisk +e2fsprogs +sysfsutils +block-mount \
	+kmod-usb-storage +kmod-usb-uhci +kmod-usb2 +kmod-usb-ohci +kmod-usb-core \
	+kmod-dummy +kmod-fs-vfat +kmod-fs-ext4 +kmod-tun \
	+iwinfo +lua +libiwinfo-lua +libuci-lua +luci-lib-nixio \
	+iputils-arping +iputils-clockdiff +iputils-tracepath \
    +dnsmasq-dhcpv6 +iputils-ping6 \
    +iw +mtr +ip +coreutils +coreutils-timeout +libopenssl
endef

define Package/wibed-system/description
	the WiFi Testbed
endef

define Package/wibed-system/conffiles
	/etc/config/wibed
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/wibed-system/install
	$(CP) ./files/* $(1)/
	echo "$(TIMESTAMP)" > files/etc/wibed.version
	echo "$(GIT_BRANCH)" >> files/etc/wibed.version	
	echo "$(GIT_HASH)" >> files/etc/wibed.version
endef

$(eval $(call BuildPackage,wibed-system))
