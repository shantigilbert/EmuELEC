# SPDX-License-Identifier: GPL-3.0
# Copyright (C) 2022-present 7Ji (pugokushin@gmail.com)

PKG_NAME="ampart"
PKG_VERSION="f0c3cc44ab05586a1b33bbddbf75432de4f1ab58"
PKG_SHA256="d069fdb05e22d86e662eb459071d92a23f08f9a7c26b5913dbdf5eb5e525872a"
PKG_LICENSE="GPL3"
PKG_SITE="https://github.com/7Ji/ampart"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_MAINTAINER="7Ji"
PKG_LONGDESC="A simple, fast, yet reliable partition tool for Amlogic's proprietary emmc partition format."
PKG_DEPENDS_TARGET="toolchain zlib u-boot-tools:host"
PKG_TOOLCHAIN="make"

post_make_target(){
  mkimage -A $TARGET_KERNEL_ARCH -O linux -T script -C none -d "$PKG_DIR/oldschool_cfgload.src" 'oldschool_cfgload'
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/sbin
  cp -a $PKG_DIR/aminstall $INSTALL/usr/sbin
  cp -a $PKG_BUILD/ampart $INSTALL/usr/sbin
  mkdir -p $INSTALL/usr/share/ampart
  cp -a $PKG_BUILD/oldschool_cfgload $INSTALL/usr/share/ampart
}
