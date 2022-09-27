# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libiconv"
PKG_VERSION="1.16"
PKG_SHA256="e6a1b1b589654277ee790cce3734f07876ac4ccfaecbee8afa0b649cf529cc04"
PKG_LICENSE="GPL"
PKG_SITE="https://savannah.gnu.org/projects/libiconv/"
PKG_URL="http://ftp.gnu.org/pub/gnu/libiconv/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A tool that converts from one character encoding to another through Unicode conversion."
PKG_BUILD_FLAGS="+pic"

PKG_CONFIGURE_OPTS_TARGET="--host=${TARGET_NAME} \
            --build=${HOST_NAME} \
            --prefix=/usr \
            --includedir=/usr/include/iconv \
            --libdir=/usr/lib/iconv \
            --sysconfdir=/etc \
            --enable-static \
            --disable-shared \
            --disable-nls \
            --disable-extra-encodings \
            --with-gnu-ld"
