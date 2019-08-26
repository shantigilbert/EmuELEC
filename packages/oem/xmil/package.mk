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

PKG_NAME="xmil"
PKG_VERSION="b07506c0cae31d260db28cb079148857d6ca2e93"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="Unknown"
PKG_SITE="https://github.com/r-type/xmil-libretro"
PKG_URL="https://github.com/r-type/xmil-libretro.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="Libretro port of X Millennium Sharp X1 emulator"
PKG_LONGDESC="Libretro port of X Millennium Sharp X1 emulator"

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"
GET_HANDLER_SUPPORT="git"

#PKG_MAKE_OPTS_TARGET="all"
make_target() {
  cd $PKG_BUILD
    make -C libretro
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp $PKG_BUILD/libretro/x1_libretro.so $INSTALL/usr/lib/libretro/
  cp x1_libretro.info $INSTALL/usr/lib/libretro/
}
