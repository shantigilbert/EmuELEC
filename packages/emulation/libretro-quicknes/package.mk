# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-quicknes"
PKG_VERSION="71b8000b33daab8ed488f8707ccd8d5b623443f8"
PKG_SHA256="c884a6610999177815d7b4c66a5821d3d5c498595c03b65936e1fd3e87593e54"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/QuickNES_Core"
PKG_URL="https://github.com/libretro/QuickNES_Core/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform"
PKG_LONGDESC="game.libretro.quicknes: QuickNES for Kodi"

PKG_LIBNAME="quicknes_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="QUICKNES_LIB"

make_target() {
  make
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
