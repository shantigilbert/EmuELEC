# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="nghttp2"
PKG_VERSION="1.48.0"
PKG_SHA256="47d8f30ee4f1bc621566d10362ca1b3ac83a335c63da7144947c806772d016e4"
PKG_LICENSE="MIT"
PKG_SITE="http://www.linuxfromscratch.org/blfs/view/cvs/basicnet/nghttp2.html"
PKG_URL="https://github.com/nghttp2/nghttp2/releases/download/v${PKG_VERSION}/nghttp2-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="nghttp2 is an implementation of HTTP/2 and its header compression algorithm, HPACK."
PKG_TOOLCHAIN="configure"

PKG_CONFIGURE_OPTS_TARGET="--enable-lib-only"

post_makeinstall_target() {
  rm -r "${INSTALL}/usr/share"
}
