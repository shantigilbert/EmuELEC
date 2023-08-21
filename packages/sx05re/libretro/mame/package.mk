# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019 Trond Haugland (trondah@gmail.com)

PKG_NAME="mame"
#PKG_VERSION="f7761a9902d59030882c58d4482446196e748c50"
#PKG_SHA256="a03ddf932b58368dee7fac0e5465a9eda1f6d07c3283facfb75714b697e96042"
PKG_VERSION="b187489b66dff418d326ec2a49e04d1c67ef37a2"
PKG_SHA256="1966b4be878f6b63bf04e928805e9aba2d836c0c3dd4ebf3f428bc99cf863da7"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/mame"
PKG_URL="https://github.com/libretro/mame/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain zlib flac sqlite expat"
PKG_SECTION="libretro"
PKG_SHORTDESC="MAME - Multiple Arcade Machine Emulator"
PKG_TOOLCHAIN="make"

pre_configure_target() {

PTR64="1"
NOASM="0"

if [ "${ARCH}" == "arm" ]; then
  NOASM="1"
fi

PKG_MAKE_OPTS_TARGET="REGENIE=1 \
		      VERBOSE=1 \
		      NOWERROR=1 \
		      OPENMP=1 \
		      CROSS_BUILD=1 \
		      TOOLS=0 \
		      RETRO=1 \
		      PTR64=${PTR64} \
		      NOASM=${NOASM} \
		      PYTHON_EXECUTABLE=python3 \
		      CONFIG=libretro \
		      LIBRETRO_OS=unix \
		      LIBRETRO_CPU=arm64 \
		      PLATFORM=arm64 \
		      ARCH= \
		      TARGET=mame \
		      SUBTARGET=mame \
		      OSD=retro \
		      USE_SYSTEM_LIB_EXPAT=1 \
		      USE_SYSTEM_LIB_ZLIB=1 \
		      USE_SYSTEM_LIB_FLAC=1 \
		      USE_SYSTEM_LIB_SQLITE3=1"

export ARCHOPTS="-D__aarch64__ -DASMJIT_BUILD_X86"

sed -i "s/-static-libstdc++//g" scripts/genie.lua

unset ARCH
unset DISTRO
unset PROJECT

}

make_target() {
  make $PKG_MAKE_OPTS_TARGET OVERRIDE_CC=$CC OVERRIDE_CXX=$CXX OVERRIDE_LD=$LD AR=$AR $MAKEFLAGS -j4
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp *.so $INSTALL/usr/lib/libretro/
  mkdir -p $INSTALL/usr/config/retroarch/savefiles/mame/hi
  cp plugins/hiscore/hiscore.dat $INSTALL/usr/config/retroarch/savefiles/mame/hi
}
