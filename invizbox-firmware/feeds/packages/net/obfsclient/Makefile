#
# Copyright (C) 2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=obfclient
PKG_VERSION:=0.1.4-1
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Yawning/obfsclient.git
PKG_SOURCE:=$(PKG_NAME).tar.gz
PKG_SOURCE_VERSION:=HEAD
PKG_SOURCE_SUBDIR:=$(PKG_NAME)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

#PKG_RELEASE:=$(PKG_VERSION)


PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/obfsclient
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=A pluggable transports proxy
  URL:=https://www.torproject.org/projects/obfsclient
  DEPENDS:=+libopenssl +glib2 +libstdcpp +libpthread +libevent2 +liballium
endef

define Package/obfsclient/description
 obfsclient - A C++11 obfs2/3 Tor managed pluggable transport client
 By design it will only function as a ClientTransportPlugin for Tor. It does use a reasonably complete implementation of the Pluggable Transport spec so when used properly, it will function as a drop in replacement for asn's Python implementation.
endef

define Package/obfsclient/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/obfsclient $(1)/usr/bin/
endef

$(eval $(call BuildPackage,obfsclient))
