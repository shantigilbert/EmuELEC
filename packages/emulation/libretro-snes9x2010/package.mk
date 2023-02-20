# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-snes9x2010"
PKG_VERSION="e86e54624a7910a64a9a744e3734d4067c48d240"
PKG_SHA256="efa887b420c4c2eafd69fde72bdfd9d76820e14864e3cebd83b4e66e463a5051"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/snes9x2010"
PKG_URL="https://github.com/libretro/snes9x2010/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform"
PKG_LONGDESC="snes9x2010 for Kodi"

PKG_LIBNAME="snes9x2010_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="SNES9X2010_LIB"

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
