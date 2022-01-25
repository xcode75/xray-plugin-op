
include $(TOPDIR)/rules.mk

PKG_NAME:=xray-plugin
PKG_VERSION:=1.5.2
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/xcode75/xray-pluginn/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=61ee038220ef50e33340e67a6073e47a8c31d29a15ab3c7741828aeba801670c

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=xcode75

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
