# SPDX-License-Identifier: GPL-3.0
# Copyright (C) 2022-present 7Ji (pugokushin@gmail.com)

PKG_NAME="ampart"
PKG_VERSION="fc4a0537f92b1bb54ce4af95b66fc0d624f6572b"
PKG_SHA256="84213abc98c109499bd373822ef3c1d352b35e56f64b4fc55fa2b48375b27571"
PKG_LICENSE="GPL3"
PKG_SITE="https://github.com/7Ji/ampart"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_MAINTAINER="7Ji"
PKG_LONGDESC="A simple, fast, yet reliable partition tool for Amlogic's proprietary emmc partition format."
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p $INSTALL/usr/sbin
  cp -a $PKG_DIR/installtointernal $INSTALL/usr/sbin
  cp -a $PKG_BUILD/ampart $INSTALL/usr/sbin
}