# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="libamcodec"
PKG_VERSION="f4cacd93b663c938fe596c5453dfe3ba40547fda"
PKG_SHA256="8e5f7a83612ce9d8a698de7e866e6e5512cc94ba8333e326484056eb5c3d1617"
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
