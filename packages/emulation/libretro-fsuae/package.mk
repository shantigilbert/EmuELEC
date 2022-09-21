# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-fsuae"
PKG_VERSION="6b98f852e00a83ecdcf497c1032882ad7b6efc99"
PKG_SHA256="0beaf41955733f30cf092e7aa7e4f5e07a64c0608783fb7e6c820711c44e4ed9"
PKG_ARCH="x86_64"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/libretro-fsuae"
PKG_URL="https://github.com/libretro/libretro-fsuae/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host libmpeg2:host glib:host libpng:host"
PKG_DEPENDS_TARGET="toolchain glib libmpeg2 openal-soft libpng libretro-fsuae:host"
PKG_LONGDESC="FS-UAE amiga emulator."
PKG_BUILD_FLAGS="-lto"
PKG_TOOLCHAIN="autotools"

PKG_LIBNAME="fsuae_libretro.so"
PKG_LIBPATH="${PKG_LIBNAME}"
PKG_LIBVAR="FSUAE_LIB"

if [ "${TARGET_ARCH}" = "arm" ] && target_has_feature neon; then
  PKG_CONFIGURE_OPTS_TARGET="--disable-jit --enable-neon"
fi

pre_configure_host() {
  cd ${PKG_BUILD}
  rm -rf .${HOST_NAME}
  # check if this flag is still needed when this package is updated
  export CFLAGS="${CFLAGS} -fcommon"
  export ac_cv_func_realloc_0_nonnull=yes
}

make_host() {
  make -j1 CC="${CC}" gen
}

makeinstall_host() {
  :
}

pre_configure_target() {
  cd ${PKG_BUILD}
  rm -rf .${TARGET_NAME}
  # check if this flag is still needed when this package is updated
  export CFLAGS="${CFLAGS} -fcommon"
  export ac_cv_func_realloc_0_nonnull=yes
}

make_target() {
  make CC="${CC}"
}

makeinstall_target() {
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}
  cp ${PKG_LIBPATH} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME}
  echo "set(${PKG_LIBVAR} ${SYSROOT_PREFIX}/usr/lib/${PKG_LIBNAME})" > ${SYSROOT_PREFIX}/usr/lib/cmake/${PKG_NAME}/${PKG_NAME}-config.cmake
}
