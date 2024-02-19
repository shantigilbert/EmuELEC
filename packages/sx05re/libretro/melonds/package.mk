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

PKG_NAME="melonds"
PKG_VERSION="c6488c88cb4c7583dbcd61609e0eef441572fae8"
PKG_SHA256="bd232af7f8b0f491891893096bec6b6a60dc1671cf12907e67f4d6dbf668e0ed"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/melonds"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="DS emulator, sorta"
PKG_LONGDESC="DS emulator, sorta"

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"
PKG_USE_CMAKE="no"



configure_target() {
  cd ${PKG_BUILD}
  PKG_MAKE_OPTS_TARGET+=" HAVE_OPENGL=0 HAVE_NEON=1"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp melonds_libretro.so ${INSTALL}/usr/lib/libretro/
}
