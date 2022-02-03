# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019 Trond Haugland (trondah@gmail.com)

PKG_NAME="mame2016"
PKG_VERSION="bcff8046328da388d100b1634718515e1b15415d"
PKG_SHA256="c4128c50e13f9ad79a9aa3ed5b7275ca34b8b01acdbaba34a5b716208a98da75"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/mame2016-libretro"
PKG_URL="https://github.com/libretro/mame2016-libretro/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="escalade"
PKG_SHORTDESC="MAME (0.174-ish) for libretro"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-lto"

PTR64="0"
NOASM="0"

if [ "$ARCH" == "aarch64" ]; then
  NOASM="1"
  PLAT=arm64
elif [ "$ARCH" == "arm" ]; then
  NOASM="1"
  PLAT=$ARCH
elif [ "$ARCH" == "x86_64" ]; then
  PTR64="1"
  PLAT=$ARCH
else
  PLAT=$ARCH
fi

PKG_MAKE_OPTS_TARGET="REGENIE=1 \
		      VERBOSE=1 \
		      NOWERROR=1 \
		      OPENMP=1 \
		      CROSS_BUILD=1 \
		      TOOLS=1 \
		      RETRO=1 \
		      PTR64=$PTR64 \
		      NOASM=$NOASM \
		      PYTHON_EXECUTABLE=python \
		      CONFIG=libretro \
		      LIBRETRO_OS=unix \
		      LIBRETRO_CPU=$PLAT \
		      PLATFORM=$PLAT \
		      ARCH= \
		      TARGET=mame \
		      SUBTARGET=arcade \
		      OSD=retro \
		      USE_SYSTEM_LIB_EXPAT=1 \
		      USE_SYSTEM_LIB_ZLIB=1 \
		      USE_SYSTEM_LIB_FLAC=1 \
		      USE_SYSTEM_LIB_SQLITE3=1"

make_target() {
  unset DISTRO
  make $PKG_MAKE_OPTS_TARGET OVERRIDE_CC=$CC OVERRIDE_CXX=$CXX OVERRIDE_LD=$LD AR=$AR $MAKEFLAGS
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/bin
  mkdir -p $INSTALL/usr/lib/libretro
  cp *.so $INSTALL/usr/lib/libretro/mame2016_libretro.so
  mkdir -p $INSTALL/usr/config/retroarch/savefiles/mame2016/hi
  cp metadata/hiscore.dat $INSTALL/usr/config/retroarch/savefiles/mame2016/hi
}

