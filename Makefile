# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=xray-plugin
PKG_VERSION:=1.5.3
PKG_RELEASE:=$(SUBTARGET)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/xcode75/xray-plugin/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=fdfade8bd19247e5145c92e6d1fb9df3479fa843c27070583e376088f3ed2918

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE


PKG_CONFIG_DEPENDS:= \
	CONFIG_XRAY_PLUGIN_COMPRESS_GOPROXY \
	CONFIG_XRAY_PLUGIN_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/xcode75/xray-plugin
GO_PKG_LDFLAGS:=-s -w

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/xray-plugin/config
config XRAY_PLUGIN_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config XRAY_PLUGIN_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifneq ($(CONFIG_XRAY_PLUGIN_COMPRESS_GOPROXY),)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.io
endif

define Package/xray-plugin
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=SIP003 plugin for Shadowsocks, based on Xray
  URL:=https://github.com/xcode75/xray-plugin
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
ifneq ($(CONFIG_XRAY_PLUGIN_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/xray-plugin
endif
endef

define Package/xray-plugin/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/xray-plugin $(1)/usr/bin/xray-plugin
endef

$(eval $(call GoBinPackage,xray-plugin))
$(eval $(call BuildPackage,xray-plugin))
