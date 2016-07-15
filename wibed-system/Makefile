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
PKG_RELEASE:=5
PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

TIMESTAMP := $(shell date -u +%Y%m%d-%H%M)
GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
GIT_HASH := $(shell git rev-parse HEAD)

include $(INCLUDE_DIR)/package.mk

define Package/wibed-system
  SECTION:=net
  CATEGORY:=WiBed
  TITLE:=Basic system requirements for Wibed
  URL:=http://confine-project.eu
  MENU:=1
  DEPENDS:= \
	+usbutils +sfdisk +e2fsprogs +sysfsutils +block-mount \
	+kmod-usb-storage +kmod-usb-uhci +kmod-usb2 +kmod-usb-ohci +kmod-usb-core \
	+kmod-dummy +kmod-fs-vfat +kmod-fs-ext4 +kmod-tun \
	+iwinfo +lua +libiwinfo-lua +libuci-lua +luci-lib-nixio \
	+iputils-arping +iputils-clockdiff +iputils-tracepath \
	+dnsmasq-dhcpv6 +iputils-ping6 +vim \
	+iw +mtr +ip +coreutils +coreutils-timeout +lua-curl \
	+openssh-client +luci-lib-libremap \
	+luci-lib-libremap-location +luci-lib-libremap-system +luci-lib-libremap-wireless \
	+luasocket +kmod-batman-adv +batctl +uhttpd +firewall +alfred +luci-base +blkid
endef

define Package/wibed-system/config
	source "$(SOURCE)/Config.in"
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

WIBED_SYSTEM_SERVER:=$(if $(CONFIG_WIBED_SYSTEM_SERVER),\
	$(CONFIG_WIBED_SYSTEM_SERVER),\
	$(strip http://wibed.confine-project.eu))

WIBED_SYSTEM_TESTBED:=$(if $(CONFIG_WIBED_SYSTEM_TESTBED),\
	$(CONFIG_WIBED_SYSTEM_TESTBED),\
	$(strip wibed))

WIBED_SYSTEM_MGMT_SSID:=$(if $(CONFIG_WIBED_SYSTEM_MGMT_SSID),\
	$(CONFIG_WIBED_SYSTEM_MGMT_SSID),\
	$(strip wibed))

WIBED_SYSTEM_MGMT_BSSID:=$(if $(CONFIG_WIBED_SYSTEM_MGMT_BSSID),\
	$(CONFIG_WIBED_SYSTEM_MGMT_BSSID),\
	$(strip "02:C0:FF:EE:C0:DE"))

WIBED_SYSTEM_MGMT_CHANNEL5:=$(if $(CONFIG_WIBED_SYSTEM_MGMT_CHANNEL5),\
	$(CONFIG_WIBED_SYSTEM_MGMT_CHANNEL5),\
	$(strip "40+"))

WIBED_SYSTEM_MGMT_CHANNEL2:=$(if $(CONFIG_WIBED_SYSTEM_MGMT_CHANNEL2),\
	$(CONFIG_WIBED_SYSTEM_MGMT_CHANNEL2),\
	$(strip "6"))

WIBED_SYSTEM_MGMT_CHANNEL2:=$(subst $\",,$(WIBED_SYSTEM_MGMT_CHANNEL2))
WIBED_SYSTEM_MGMT_CHANNEL5:=$(subst $\",,$(WIBED_SYSTEM_MGMT_CHANNEL5))

WIBED_SYSTEM_ROOT_PASSWORD:=$(if $(CONFIG_WIBED_SYSTEM_ROOT_PASSWORD),\
	$(CONFIG_WIBED_SYSTEM_ROOT_PASSWORD),\
	$(strip ""))

ifdef CONFIG_WIBED_SYSTEM_GW
	WIBED_SYSTEM_GW:="1"
else
	WIBED_SYSTEM_GW:="0"
endif

#$(SED) "s~.*option api_url.*~\t option api_url \'$(strip $(WIBED_SYSTEM_SERVER))\'~g"\
#		"$(1)/etc/wibed.default-config")

define Package/wibed-system/install
	echo $(strip $(WIBED_SYSTEM_MGMT_CHANNEL5))
	echo $(strip $(WIBED_SYSTEM_MGMT_CHANNEL2))
	echo $(WIBED_SYSTEM_MGMT_CHANNEL5)
	echo $(WIBED_SYSTEM_MGMT_CHANNEL2)
	$(CP) ./files/* $(1)/
	$(if $(CONFIG_WIBED_SYSTEM_SERVER),\
		$(SED) "s~.*option api_url.*~\t option api_url \'$(strip $(WIBED_SYSTEM_SERVER))\'~g"\
		"$(1)/etc/wibed.default-config")
	$(SED) "s~.*option save_url.*~\t option save_url \'$(strip $(WIBED_SYSTEM_SERVER))api/results\'~g"\
		"$(1)/etc/wibed.default-config"
	$(SED) "s~.*option testbed.*~\t option testbed \'$(strip $(WIBED_SYSTEM_TESTBED))\'~g"\
		"$(1)/etc/wibed.default-config"
	$(SED) "s~.*option ssid.*~\t option ssid \'$(strip $(WIBED_SYSTEM_MGMT_SSID))\'~g"\
		"$(1)/etc/wibed.default-config"
	$(SED) "s~.*option bssid.*~\t option bssid \'$(strip $(WIBED_SYSTEM_MGMT_BSSID))\'~g"\
		"$(1)/etc/wibed.default-config"
	$(SED) "s~.*option channel5.*~\t option channel5 \'$(strip $(WIBED_SYSTEM_MGMT_CHANNEL5))\'~g"\
		"$(1)/etc/wibed.default-config"
	$(SED) "s~.*option channel2.*~\t option channel2 \'$(strip $(WIBED_SYSTEM_MGMT_CHANNEL2))\'~g"\
		"$(1)/etc/wibed.default-config"
	$(SED) "s~.*option is_gw.*~\t option is_gw \'$(WIBED_SYSTEM_GW)\'~g"\
		"$(1)/etc/wibed.default-config"
	$(SED) "s~.*option root_password.*~\t option root_password \'$(strip $(WIBED_SYSTEM_ROOT_PASSWORD))\'~g"\
		"$(1)/etc/wibed.default-config"
	$(INSTALL_DIR) $(1)/save
	echo "$(TIMESTAMP)" > $(1)/etc/wibed.version
	echo "$(GIT_BRANCH)" >> $(1)/etc/wibed.version
	echo "$(GIT_HASH)" >> $(1)/etc/wibed.version
endef

$(eval $(call BuildPackage,wibed-system))
