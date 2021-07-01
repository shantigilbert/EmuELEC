# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-fceumm-mod"
PKG_VERSION="2ce3c904ce3eebe10e14dbeb6438f959ab6c88d2"
PKG_SHA256="a3995719b567eded7d1d31ec2a89a4900730bf611071322a3afa5bafdd5464ff"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/Tippek/libretro-fceumm-mod"
PKG_URL="https://github.com/Tippek/libretro-fceumm-mod/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform"
PKG_LONGDESC="game.libretro.fceumm: FCEUmm modified emulator for Kodi"

PKG_LIBNAME="fceumm-mod_libretro.so"
PKG_LIBPATH="$PKG_LIBNAME"
PKG_LIBVAR="FCEUMM-MOD_LIB"

make_target() {
  make -f Makefile.libretro
}

makeinstall_target() {
  mkdir -p $SYSROOT_PREFIX/usr/lib/cmake/$PKG_NAME
  cp $PKG_LIBPATH $SYSROOT_PREFIX/usr/lib/$PKG_LIBNAME
  echo "set($PKG_LIBVAR $SYSROOT_PREFIX/usr/lib/$PKG_LIBNAME)" > $SYSROOT_PREFIX/usr/lib/cmake/$PKG_NAME/$PKG_NAME-config.cmake
}
