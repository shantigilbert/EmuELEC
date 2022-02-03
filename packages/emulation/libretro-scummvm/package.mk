# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-scummvm"
PKG_VERSION="63e57573a9ffe71a1083ff46d9cd210203b87afb"
PKG_SHA256="b5be836e068caf16418d3fde87c6ba436b31d87e1d9627855ba463bb0841a5d5"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/scummvm"
PKG_URL="https://github.com/libretro/scummvm/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform"
PKG_LONGDESC="game.libretro.scummvm: scummvm for Kodi"
PKG_TOOLCHAIN="make"

PKG_LIBNAME="scummvm_libretro.so"
PKG_LIBPATH="backends/platform/libretro/build/${PKG_LIBNAME}"
PKG_LIBVAR="SCUMMVM_LIB"

PKG_MAKE_OPTS_TARGET="-C backends/platform/libretro/build/"

pre_make_target() {
  cd ${PKG_BUILD}
  CXXFLAGS+=" -DHAVE_POSIX_MEMALIGN=1"
  export AR+=" cru"
  export LD="${CC}"
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
