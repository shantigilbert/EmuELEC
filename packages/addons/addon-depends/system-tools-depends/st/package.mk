# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="st"
PKG_VERSION="0.8.5"
PKG_SHA256="ea6832203ed02ff74182bcb8adaa9ec454c8f989e79232cb859665e2f544ab37"
PKG_ARCH="x86_64"
PKG_LICENSE="GPL"
PKG_SITE="https://st.suckless.org/"
PKG_URL="https://dl.suckless.org/st/st-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libX11 libXft libXrender fontconfig freetype ncurses"
PKG_LONGDESC="A simple terminal implementation for X"
PKG_BUILD_FLAGS="-sysroot"

PKG_MAKE_OPTS_TARGET="X11INC=$(get_build_dir libXft)/include \
                      X11LIB=$(get_build_dir libXft)/.${TARGET_NAME}/src/.libs"

pre_configure_target() {
  LDFLAGS="-lXrender ${LDFLAGS}"
}
