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

PKG_NAME="mame2003-plus"
PKG_VERSION="53007da5d3839dc041baeb6cc8e48a245df988e3"
PKG_SHA256="dfca32219ae254dfba39bd594d37078a15a59d2fb911f59516861f6971337546"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="MAME"
PKG_SITE="https://github.com/libretro/mame2003-plus-libretro"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="MAME - Multiple Arcade Machine Emulator"
PKG_LONGDESC="MAME - Multiple Arcade Machine Emulator"

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"

make_target() {
  make ARCH="" CC="$CC" NATIVE_CC="$CC" LD="$CC"
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp mame2003_plus_libretro.so $INSTALL/usr/lib/libretro/
}
