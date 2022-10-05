# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libass"
PKG_VERSION="0.16.0"
PKG_SHA256="5dbde9e22339119cf8eed59eea6c623a0746ef5a90b689e68a090109078e3c08"
PKG_LICENSE="BSD"
PKG_SITE="https://github.com/libass/libass"
PKG_URL="https://github.com/libass/libass/releases/download/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain freetype fontconfig fribidi harfbuzz"
PKG_LONGDESC="A portable subtitle renderer for the ASS/SSA (Advanced Substation Alpha/Substation Alpha) subtitle format."

PKG_CONFIGURE_OPTS_TARGET="--disable-test \
                           --enable-fontconfig \
                           --disable-silent-rules \
                           --with-gnu-ld"

if [ ${TARGET_ARCH} = "x86_64" ]; then
  PKG_DEPENDS_TARGET+=" nasm:host"
  PKG_CONFIGURE_OPTS_TARGET+=" --enable-asm"
fi

post_configure_target() {
  libtool_remove_rpath libtool
}
