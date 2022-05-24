# SPDX-License-Identifier: GPL-3.0
# Copyright (C) 2022-present 7Ji (pugokushin@gmail.com)

PKG_NAME="ampart"
PKG_VERSION="91526114668b3fc0708d4df9525b6a5eccd47c70"
PKG_SHA256="d856bfb981b5861b08c2896d2382186b473a4ded9a9b362d13da608dc0df932f"
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
