# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-uae"
PKG_VERSION="5c3d76b3472ae7effe7d9fadbbcf0c17a58827df"
PKG_SHA256="97fe017e2d93fdb2a4e5a52aac543dab3015e01b290c55c56b3a4933e5f7bb7a"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libretro/libretro-uae"
PKG_URL="https://github.com/libretro/libretro-uae/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform"
PKG_LONGDESC="libretro wrapper for UAE emulator."
PKG_BUILD_FLAGS="-lto"

PKG_LIBNAME="puae_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="UAE_LIB"

pre_configure_target() {
  CFLAGS+=" -fcommon"
  if [ "${TARGET_ARCH}" = "arm" ]; then
    CFLAGS+=" -DARM -marm"
  fi
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
