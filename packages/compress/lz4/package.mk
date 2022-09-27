# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="lz4"
PKG_VERSION="1.9.3"
PKG_SHA256="030644df4611007ff7dc962d981f390361e6c97a34e5cbc393ddfbe019ffe2c1"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/lz4/lz4"
PKG_URL="https://github.com/lz4/lz4/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="lz4 data compressor/decompressor"
PKG_TOOLCHAIN="cmake"

configure_package() {
  PKG_CMAKE_SCRIPT="${PKG_BUILD}/build/cmake/CMakeLists.txt"

  PKG_CMAKE_OPTS_TARGET="-DBUILD_SHARED_LIBS=0 -DCMAKE_POSITION_INDEPENDENT_CODE=0"
}

post_makeinstall_target() {
  rm -rf ${INSTALL}
}
