#
# Copyright (C) 2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=liballium
PKG_VERSION:=2014-05-09
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Yawning/liballium.git
PKG_SOURCE:=$(PKG_NAME).tar.gz
PKG_SOURCE_VERSION:=HEAD
PKG_SOURCE_SUBDIR:=$(PKG_NAME)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/liballium
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A pluggable transports library
  URL:=https://www.torproject.org/projects/obfsclient
endef



define Package/liballium/description
 liballium: A C Tor Pluggable Transports Utility Library
 liballium attempts to reduce the amount of boilerplate code required to implement pluggable transports for Tor in C or C++.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/allium
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/allium/*.h $(1)/usr/include/allium
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liballium*.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/liballium*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/liballium/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liballium*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,liballium))
