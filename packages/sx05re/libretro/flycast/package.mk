################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING.  If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston, MA 02110, USA.
#  http://www.gnu.org/copyleft/gpl.html
################################################################################

PKG_NAME="flycast"

if [[ "${PROJECT}" == "Amlogic" ]]; then
PKG_VERSION="0e10e86ea9ca0f8655c98909da7a845e7643b36f"
PKG_SHA256="3a0e72a3c358520db2035c69f39fa1322ce024548dcc57afc1b2c822a47ac4a0"
PKG_PATCH_DIRS="Amlogic"
else
PKG_VERSION="b941ea2f6598f971964c57c058b55ac239a242fe"
PKG_SHA256="588cffe618c7ac8c4aeb4545e8adebad7c185fbe0b2c23899c80e2e3d69431bc"
fi
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/flycast"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain $OPENGLES"
PKG_LONGDESC="Flycast is a multiplatform Sega Dreamcast emulator "
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-gold"

pre_configure_target() {
# Flycast defaults to -O3 but then CHD v5 do not seem to work on EmuELEC so we change it to -O2 to fix the issue
PKG_MAKE_OPTS_TARGET="ARCH=arm HAVE_OPENMP=0 GIT_VERSION=${PKG_VERSION:0:7} FORCE_GLES=1 SET_OPTIM=-O2 HAVE_LTCG=0"

if [ "${ARCH}" == "aarch64" ]; then
PKG_MAKE_OPTS_TARGET+=" WITH_DYNAREC=arm64"
fi
}

pre_make_target() {
   export BUILD_SYSROOT=$SYSROOT_PREFIX

  if [ "$OPENGLES_SUPPORT" = "yes" ]; then
    PKG_MAKE_OPTS_TARGET+=" FORCE_GLES=1 LDFLAGS=-lrt"
  fi

if [ "${ARCH}" == "aarch64" ]; then
  case $PROJECT in
    Amlogic-ng)
      PKG_MAKE_OPTS_TARGET+=" platform=odroid-n2"
      ;;
    Amlogic)
      PKG_MAKE_OPTS_TARGET+=" platform=arm64"
    ;;  
  esac
else
   case $PROJECT in
    Amlogic-ng)
      PKG_MAKE_OPTS_TARGET+=" platform=AMLG12B"
      ;;
    Amlogic)
      PKG_MAKE_OPTS_TARGET+=" platform=AMLGX"
    ;;  
  esac
fi
  
 if [ "$DEVICE" == "OdroidGoAdvance" ] || [ "$DEVICE" == "GameForce" ]; then
	if [ "$ARCH" == "arm" ]; then
	PKG_MAKE_OPTS_TARGET+=" platform=classic_armv8_a35"
	else
	PKG_MAKE_OPTS_TARGET+=" platform=arm64"
	fi
 fi 
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  if [ "${ARCH}" == "aarch64" ]; then
	cp flycast_libretro.so $INSTALL/usr/lib/libretro/
  else
	cp flycast_libretro.so $INSTALL/usr/lib/libretro/flycast_32b_libretro.so
  fi
}
