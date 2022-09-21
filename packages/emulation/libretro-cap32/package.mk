# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-cap32"
PKG_VERSION="dc70139d067291cccf7ce726dfa1da7de2f65ccf"
PKG_SHA256="b236669fe745ada36beef3a82491be8b6fa3752be6bf32bbece6b03f40af1291"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/libretro-cap32"
PKG_URL="https://github.com/libretro/libretro-cap32/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform"
PKG_LONGDESC="game.libretro.cap32: cap32 for Kodi"

PKG_LIBNAME="cap32_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="CAP32_LIB"

make_target() {
  make
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
