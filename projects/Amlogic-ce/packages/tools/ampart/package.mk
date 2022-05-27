# SPDX-License-Identifier: GPL-3.0
# Copyright (C) 2022-present 7Ji (pugokushin@gmail.com)

PKG_NAME="ampart"
PKG_VERSION="7ddfc2a4d1adf1fe8cc9b3774a9cd9f0386e6deb"
PKG_SHA256="7504bfa2da7a4e42039afea60519cac3ab6c84f4373722efd19969e1906cf785"
PKG_LICENSE="GPL3"
PKG_SITE="https://github.com/7Ji/ampart"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_MAINTAINER="7Ji"
PKG_LONGDESC="A simple, fast, yet reliable partition tool for Amlogic's proprietary emmc partition format."
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="make"

make_target() {
  make
  mkimage -A $TARGET_KERNEL_ARCH -O linux -T script -C none -d "$PKG_DIR/oldschool_cfgload.src" 'oldschool_cfgload'
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/sbin
  cp -a $PKG_DIR/aminstall $INSTALL/usr/sbin
  cp -a $PKG_BUILD/ampart $INSTALL/usr/sbin
  mkdir -p $INSTALL/usr/share/ampart
  cp -a $PKG_BUILD/oldschool_cfgload $INSTALL/usr/share/ampart
}
