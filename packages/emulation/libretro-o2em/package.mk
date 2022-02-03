# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-o2em"
PKG_VERSION="c039e83f2589cb9d21b9aa5dc211954234ab8c97"
PKG_SHA256="63f8ab5feed119f092ba102a66cfe32f5e5c5279928e3a71f01df503c5390d4a"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/libretro-o2em"
PKG_URL="https://github.com/libretro/libretro-o2em/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform"
PKG_LONGDESC="game.libretro.o2em: o2em for Kodi"

PKG_LIBNAME="o2em_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="O2EM_LIB"

make_target() {
  make
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
