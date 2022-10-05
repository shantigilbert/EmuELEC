# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-fbneo"
PKG_VERSION="af50579270a610eda8ac580648d9c12acc7bb565"
PKG_SHA256="904c09c9901ef12c63047465022b80c82787679ee3ea6198268e58f4d9c0647a"
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

  # libretro-fbneo does not need / nor build successfully with _FILE_OFFSET_BITS or _TIME_BITS set
  if [ "${TARGET_ARCH}" = "arm" ]; then
    export CFLAGS=$(echo ${CFLAGS} | sed -e "s|-D_FILE_OFFSET_BITS=64||g")
    export CFLAGS=$(echo ${CFLAGS} | sed -e "s|-D_TIME_BITS=64||g")
    export CXXFLAGS=$(echo ${CXXFLAGS} | sed -e "s|-D_FILE_OFFSET_BITS=64||g")
    export CXXFLAGS=$(echo ${CXXFLAGS} | sed -e "s|-D_TIME_BITS=64||g")
  fi
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
