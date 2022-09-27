# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libidn2"
PKG_VERSION="2.3.2"
PKG_SHA256="76940cd4e778e8093579a9d195b25fff5e936e9dc6242068528b437a76764f91"
PKG_LICENSE="LGPL3"
PKG_SITE="https://www.gnu.org/software/libidn/"
PKG_URL="http://ftpmirror.gnu.org/gnu/libidn/libidn2-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Free software implementation of IDNA2008, Punycode and TR46."

PKG_CONFIGURE_OPTS_TARGET="--disable-doc \
                           --enable-shared \
                           --disable-static"

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/bin
}
