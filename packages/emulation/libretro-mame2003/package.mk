# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-mame2003"
PKG_VERSION="d0ed1a565803cfada9f4088326eae616f6e5f8a3"
PKG_SHA256="eb369e1616b0556c084f0016fbe6c9b589fafed470a248cd9390d7361f59e6f5"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/mame2003-libretro"
PKG_URL="https://github.com/libretro/mame2003-libretro/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Late 2003 version of MAME (0.78) for libretro"

PKG_LIBNAME="mame2003_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="MAME2003_LIB"

configure_target() {
  export LD="${CC}"
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
