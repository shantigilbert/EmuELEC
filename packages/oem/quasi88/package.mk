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

PKG_NAME="quasi88"
PKG_VERSION="f4ee004905a091fc9fdaae58df2d365b6bae2fa4"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="Unknown"
PKG_SITE="https://github.com/libretro/quasi88-libretro"
PKG_URL="https://github.com/libretro/quasi88-libretro.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="A port of QUASI88, a PC-8800 series emulator by Showzoh Fukunaga, to the libretro API"
PKG_LONGDESC="A port of QUASI88, a PC-8800 series emulator by Showzoh Fukunaga, to the libretro API"

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"
GET_HANDLER_SUPPORT="git"
makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp quasi88_libretro.so $INSTALL/usr/lib/libretro/
}
