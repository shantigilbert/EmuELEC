# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="libamcodec"
PKG_VERSION="dcd4999ba708fc84e4662c39262bbbcf92219ed9"
PKG_SHA256="3b987f85a11a19835d471757f5eab13b0bb7356202275c08ff4a6b6fd7cf3758"
PKG_LICENSE="proprietary"
PKG_SITE="http://openlinux.amlogic.com"
PKG_URL="https://sources.coreelec.org/$PKG_NAME-$ARCH-$PKG_VERSION.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libamplayer: Interface library for Amlogic media codecs"
PKG_TOOLCHAIN="manual"

make_target() {
  cp -PR * $SYSROOT_PREFIX
}

makeinstall_target() {
  mkdir -p $INSTALL/usr
    cp -PR usr/lib $INSTALL/usr
}
