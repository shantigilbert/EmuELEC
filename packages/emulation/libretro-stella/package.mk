# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-stella"
PKG_VERSION="1351a4fe2ca6b1f3a66c7db0df2ec268ab002d41"
PKG_SHA256="7836f41bf95a345735701e818e340ffcfa008542bb5ad0b2f760d807bd3b3620"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/stella-libretro"
PKG_URL="https://github.com/libretro/stella2014-libretro/archive/${PKG_VERSION}.tar.gz"
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
