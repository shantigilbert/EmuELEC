# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-fmsx"
PKG_VERSION="0abd34399c756a8767edf7ccd28b940335312a8e"
PKG_SHA256="3f979dfa3dba4f7ac32d89a86f6c2a8ebf5f81ad29026d2a5a4180d20068c65f"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/fmsx-libretro"
PKG_URL="https://github.com/libretro/fmsx-libretro/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform"
PKG_LONGDESC="game.libretro.fmsx: fmsx for Kodi"

PKG_LIBNAME="fmsx_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="FMSX_LIB"

make_target() {
  make
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
