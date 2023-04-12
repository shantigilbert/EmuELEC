# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libzen"
PKG_VERSION="0.4.40"
PKG_SHA256="0c2e1c7302b3ee260d34b52e4b16ab655bdf021db8c14653e418aced46eb24a7"
PKG_LICENSE="GPL"
PKG_SITE="https://mediaarea.net/en/MediaInfo/"
PKG_URL="https://mediaarea.net/download/source/libzen/${PKG_VERSION}/libzen_${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="MediaInfo is a convenient unified display of the most relevant technical and tag data for video and audio files"
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-sysroot"

configure_target() {
  cd Project/GNU/Library
  do_autoreconf
  ./configure \
        --host=${TARGET_NAME} \
        --build=${HOST_NAME} \
        --enable-static \
        --disable-shared \
        --prefix=/usr
}

make_target() {
  make
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/include/ZenLib ${INSTALL}/usr/lib/pkgconfig
  cp -aP ../../../Source/ZenLib/*.h ${INSTALL}/usr/include/ZenLib
  for i in HTTP_Client Format/Html Format/Http; do
    mkdir -p ${INSTALL}/usr/include/ZenLib/${i}/
    cp -aP ../../../Source/ZenLib/${i}/*.h ${INSTALL}/usr/include/ZenLib/${i}/
  done
  cp -P .libs/* ${INSTALL}/usr/lib
  cp -P libzen.pc ${INSTALL}/usr/lib/pkgconfig
}
