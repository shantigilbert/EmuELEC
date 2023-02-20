# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-fbneo"
PKG_VERSION="c68d212443c8fef7cea79b1548c64d18baed0ff5"
PKG_SHA256="bbc07a6cea3ccf573486962a267553b03a9b5ea026810123e7c39bb05b41131e"
PKG_LICENSE="OSS"
PKG_SITE="https://github.com/libretro/FBNeo"
PKG_URL="https://github.com/libretro/FBNeo/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform"
PKG_LONGDESC="game.libretro.fbneo: FinalBurn Neo GameClient for Kodi"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-gold +lto"

PKG_LIBNAME="fbneo_libretro.so"
PKG_LIBPATH="src/burner/libretro/${PKG_LIBNAME}"
PKG_LIBVAR="FBNEO_LIB"

PKG_MAKE_OPTS_TARGET="-C src/burner/libretro/ GIT_VERSION=${PKG_VERSION:0:7}"

pre_configure_target() {
  if [ "${ARCH}" = "arm" ]; then
    PKG_MAKE_OPTS_TARGET+=" platform=armv"

    # NEON Support
    if target_has_feature neon; then
      PKG_MAKE_OPTS_TARGET+="-neon"
    fi
  fi
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
