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

PKG_NAME="fuse-libretro"
PKG_VERSION="847dbbd6f787823ac9a5dfacdd68ab181063374e"
PKG_SHA256="87ec7826021704e2aa6f35224f334201d4d6bf56cabd11e5c9ebc6e736360866"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/fuse-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="A port of the Fuse Unix Spectrum Emulator to libretro "
PKG_LONGDESC="A port of the Fuse Unix Spectrum Emulator to libretro "

PKG_TOOLCHAIN="make"

make_target() {
if [ "${DEVICE}" == "Amlogic-ng" ] || [ "${DEVICE}" == "Amlogic-ogu" ]; then
  make -f Makefile.libretro platform=rpi4_64
 else
  make -f Makefile.libretro platform=rpi3_64 
fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp fuse_libretro.so ${INSTALL}/usr/lib/libretro/
}
