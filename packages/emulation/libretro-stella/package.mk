# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-stella"
PKG_VERSION="1a2e96bc6ccf91de6fb4322048da05f67a9d21d4"
PKG_SHA256="f4037d008685b4ee7a6f18a39f9b69c3e9e58be15b4b947a8e165516623e1a6d"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/stella-libretro"
PKG_URL="https://github.com/libretro/stella-libretro/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform"
PKG_LONGDESC="game.libretro.stella: Stella for Kodi"

PKG_LIBNAME="stella2014_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="STELLA_LIB"

make_target() {
  make
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
