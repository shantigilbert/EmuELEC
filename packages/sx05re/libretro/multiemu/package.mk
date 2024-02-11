# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019 Trond Haugland (trondah@gmail.com)

PKG_NAME="multiemu"
PKG_VERSION="68520cf9defd1c2762bca7f266f13ad593b7b3f3"
PKG_SHA256="3814f361fb0893269707dfd8223bcb1fb62ffcdf2baa060ee068f9d5db8164c6"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/mame"
PKG_URL="https://github.com/libretro/mame/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain zlib flac sqlite expat"
PKG_SECTION="libretro"
PKG_SHORTDESC="Fmtowns and pgm2 MAME -  Multiple Arcade Machine Emulator"
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
		      SUBTARGET=multiemu \
		      SOURCES=fujitsu/fmtowns.cpp,igs/pgm2.cpp,igs/pgm.cpp,igs/pgm3.cpp \
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
  make $PKG_MAKE_OPTS_TARGET OVERRIDE_CC=$CC OVERRIDE_CXX=$CXX OVERRIDE_LD=$LD AR=$AR $MAKEFLAGS -j5
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp *.so $INSTALL/usr/lib/libretro/
  mkdir -p ${INSTALL}/usr/config/emuelec/configs/multiemu
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/emuelec/configs/multiemu
  cp -rf $PKG_BUILD/hash/fmtowns_cd.xml ${INSTALL}/usr/config/emuelec/configs/multiemu/hash
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
}
