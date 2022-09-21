# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="wavpack"
PKG_VERSION="5.5.0"
PKG_SHA256="ef749d98df46925bc2916993e601cc7ee9114d99653e63e0e304f031ba73b8e6"
PKG_LICENSE="BSD"
PKG_SITE="https://www.wavpack.com"
PKG_URL="https://www.wavpack.com/wavpack-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain libiconv"
PKG_LONGDESC="Audio compression format providing lossless, high-quality lossy and hybrid compression mode."

PKG_CMAKE_OPTS_TARGET="-DBUILD_TESTING=OFF \
                       -DCMAKE_INSTALL_INCLUDEDIR=include/wavpack \
                       -DWAVPACK_BUILD_PROGRAMS=OFF \
                       -DWAVPACK_BUILD_DOCS=OFF \
                       -DWAVPACK_ENABLE_ASM=OFF \
                       -DWAVPACK_INSTALL_DOCS=OFF"
