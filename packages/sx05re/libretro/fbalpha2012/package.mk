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

PKG_NAME="fbalpha2012"
PKG_VERSION="23f98fc7cf4f2f216149c263cf5913d2e28be8d4"
PKG_SHA256="74a222c998c8a2ea40b992515329a894d1770933f4a557bfb37d2de28bb316ca"
PKG_ARCH="any"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/libretro/fbalpha2012"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="Port of Final Burn Alpha 2012 to Libretro"
PKG_TOOLCHAIN="make"

make_target() {
  cd svn-current/trunk
  if [ "$ARCH" == "arm" ]; then
    make -f makefile.libretro platform=armv CC=$CC CXX=$CXX
  else
    make -f makefile.libretro CC=$CC CXX=$CXX
  fi
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp fbalpha2012_libretro.so $INSTALL/usr/lib/libretro/
}
