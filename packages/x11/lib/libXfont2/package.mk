# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libXfont2"
PKG_VERSION="2.0.5"
PKG_SHA256="aa7c6f211cf7215c0ab4819ed893dc98034363d7b930b844bb43603c2e10b53e"
PKG_LICENSE="OSS"
PKG_SITE="http://www.X.org"
PKG_URL="http://xorg.freedesktop.org/archive/individual/lib/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain util-macros xtrans freetype libfontenc"
PKG_LONGDESC="X font Library"

PKG_CONFIGURE_OPTS_TARGET="--disable-ipv6 \
                           --enable-freetype \
                           --enable-builtins \
                           --disable-pcfformat \
                           --disable-bdfformat \
                           --disable-snfformat \
                           --enable-fc \
                           --with-gnu-ld \
                           --without-xmlto"

post_configure_target() {
  libtool_remove_rpath libtool
}
