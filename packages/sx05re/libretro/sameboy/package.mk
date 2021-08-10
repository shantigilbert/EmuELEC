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

PKG_NAME="sameboy"
PKG_VERSION="120ada4232cdc63e03a408bfc8e83b96e2ee07d8"
PKG_SHA256="b4dd295d32ecc04adcc202792b415c9802507fb0a9d1abe7da97c73570038764"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/libretro/sameboy"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_GIT_CLONE_BRANCH="buildbot"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="Gameboy and Gameboy Color emulator written in C"
PKG_LONGDESC="Gameboy and Gameboy Color emulator written in C"

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"

make_target() {
  make -C libretro
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp libretro/sameboy_libretro.so $INSTALL/usr/lib/libretro/
}
