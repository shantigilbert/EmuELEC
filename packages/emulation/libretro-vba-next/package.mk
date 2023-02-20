# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-vba-next"
PKG_VERSION="4191e09e2b0fcf175a15348c1fa8a12bbc6320dd"
PKG_SHA256="afbe59106a9709622f0384eed9641224a475842720eb9aefbfc6edff166222b8"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/vba-next"
PKG_URL="https://github.com/libretro/vba-next/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform"
PKG_LONGDESC="game.libretro.vba-next: VBA-Next for Kodi"

PKG_LIBNAME="vba_next_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="VBA-NEXT_LIB"

make_target() {
  make -f Makefile.libretro
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
