# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="opentyrian"
PKG_VERSION="38a6308414ed116bd7a87410c0341ab5fb21cb9b"
PKG_SHA256="cb0927f2006f216da9d053674a15f6cd91478064cce0d47000b1cb861b2b078e"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL2"
PKG_SITE="https://github.com/opentyrian/opentyrian"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="An open-source port of the DOS shoot-em-up Tyrian."
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p $INSTALL/usr/bin
  cp opentyrian $INSTALL/usr/bin
  
  mkdir -p $INSTALL/usr/config/opentyrian
  cp -r $PKG_DIR/config/* $INSTALL/usr/config/opentyrian
}
