# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="tiff"
PKG_VERSION="4.4.0"
PKG_SHA256="917223b37538959aca3b790d2d73aa6e626b688e02dcda272aec24c2f498abed"
PKG_LICENSE="OSS"
PKG_SITE="http://www.remotesensing.org/libtiff/"
PKG_URL="http://download.osgeo.org/libtiff/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libjpeg-turbo zlib"
PKG_LONGDESC="libtiff is a library for reading and writing TIFF files."
PKG_BUILD_FLAGS="+pic"
PKG_TOOLCHAIN="configure"

PKG_CONFIGURE_OPTS_TARGET="--enable-static \
                           --disable-shared \
                           --disable-mdi \
                           --disable-jbig \
                           --disable-lzma \
                           --disable-zstd \
                           --disable-webp \
                           --enable-cxx \
                           --with-jpeg-lib-dir=${SYSROOT_PREFIX}/usr/lib \
                           --with-jpeg-include-dir=${SYSROOT_PREFIX}/usr/include \
                           --without-x"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/bin
}
