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

PKG_NAME="prosystem"
PKG_VERSION="4202ac5bdb2ce1a21f84efc0e26d75bb5aa7e248"
PKG_SHA256="7ede172f560ae79b0a5420f7be388d2c99f6cd1585547b021e85de6f32ccc87f"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/prosystem-libretro"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="Port of ProSystem to libretro."
PKG_LONGDESC="Port of ProSystem to libretro."

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp prosystem_libretro.so $INSTALL/usr/lib/libretro/
}
