# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-handy"
PKG_VERSION="5145f79bb746f6d9c0b340c2f9cc4bf059848924"
PKG_SHA256="fcb505d6f2c88af621e485af59c2ca9d073b419bc05edf28d2a47a453c3f21be"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/libretro-handy"
PKG_URL="https://github.com/libretro/libretro-handy/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform"
PKG_LONGDESC="game.libretro.handy: handy for Kodi"

PKG_LIBNAME="handy_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="HANDY_LIB"

make_target() {
  make
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
