# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="ccid"
PKG_VERSION="1.5.1"
PKG_SHA256="e7a78c398ec0d617a4f98bac70d5b64f78689284dd0ae87d4692e2857f117377"
PKG_LICENSE="LGPL"
PKG_SITE="https://ccid.apdu.fr"
PKG_URL="https://ccid.apdu.fr/files/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain pcsc-lite"
PKG_LONGDESC="A generic USB Chip/Smart Card Interface Devices driver."
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--enable-static --enable-twinserial"

post_configure_target() {
  libtool_remove_rpath libtool
}

make_target() {
  make
  make -C src/ Info.plist
}
