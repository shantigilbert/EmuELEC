# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="xz"
PKG_VERSION="5.2.6"
PKG_SHA256="e076ba3439cb7cfc45b908c869f51a8c89f3c9ee9ee982fde28849c015e723a7"
PKG_LICENSE="GPL"
PKG_SITE="https://tukaani.org/xz/"
PKG_URL="https://tukaani.org/xz/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="ccache:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A free general-purpose data compression software with high compression ratio."
PKG_BUILD_FLAGS="+pic +pic:host"

# never build shared or k0p happens when building
# on fedora due to host selinux/liblzma
PKG_CONFIGURE_OPTS_HOST="--disable-shared --enable-static \
                         --disable-lzmadec \
                         --disable-lzmainfo \
                         --enable-lzma-links \
                         --disable-scripts \
                         --disable-nls"

PKG_CONFIGURE_OPTS_TARGET="--disable-shared --enable-static"

post_makeinstall_target() {
  rm -rf ${INSTALL}
}
