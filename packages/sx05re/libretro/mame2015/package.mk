################################################################################
#      This file is part of LibreELEC - http://www.libreelec.tv
#      Copyright (C) 2016 Team LibreELEC
#
#  LibreELEC is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  LibreELEC is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with LibreELEC.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

PKG_NAME="mame2015"
PKG_VERSION="2599c8aeaf84f62fe16ea00daa460a19298c121c"
PKG_SHA256="8f9a295f5d280130101c473e9754ec68ccbf45a1c1fe72d3405183ee6270b50d"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/mame2015-libretro"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="libretro"
PKG_SHORTDESC="Late 2014/Early 2015 version of MAME (0.160-ish) for libretro. Compatible with MAME 0.160 romsets."
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-lto"

pre_make_target() {
  export REALCC=$CC
  export CC=$CXX
  export LD=$CXX
}

pre_configure_target() {
  case $PROJECT in
    RPi|Slice)
     PKG_MAKE_OPTS_TARGET=" platform=armv6-hardfloat-arm1176jzf-s"
      ;;
    RPi2|Slice3)
      PKG_MAKE_OPTS_TARGET=" platform=armv7-neon-hardfloat-cortex-a7"
      ;;
    imx6)
     PKG_MAKE_OPTS_TARGET=" platform=armv7-neon-hardfloat-cortex-a9"
      ;;
    WeTek_Play)
      PKG_MAKE_OPTS_TARGET=" platform=armv7-neon-hardfloat-cortex-a9"
      ;;
    Odroid_C2|WeTek_Hub|WeTek_Play_2)
      PKG_MAKE_OPTS_TARGET=" platform=armv-neon-hardfloat"
      ;;
    Amlogic*)
     PKG_MAKE_OPTS_TARGET=" platform=armv8-neon-hardfloat-cortex-a53"
      ;;
    Generic)
      PKG_MAKE_OPTS_TARGET=""
      ;;
    *)
      PKG_MAKE_OPTS_TARGET=" platform=armv"
      ;;
  esac
  
  if [ "$DEVICE" == "Amlogic"* ]; then 
	PKG_MAKE_OPTS_TARGET=" platform=armv8-neon-hardfloat-cortex-a53"
  fi

  if [ "$DEVICE" == "OdroidGoAdvance" ] || [ "$DEVICE" == "GameForce" ]; then 
	PKG_MAKE_OPTS_TARGET=" platform=armv8-neon-hardfloat-cortex-a35"
  fi
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp mame*_libretro.so $INSTALL/usr/lib/libretro/
}
