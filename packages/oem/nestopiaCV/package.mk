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

PKG_NAME="nestopiaCV"
PKG_VERSION="2ef9f54159a3da268545f338842bf8a7bbd5e66c"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/asakous/NestopiaCV"
PKG_URL="https://github.com/asakous/NestopiaCV.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="Libretro implementation of NEStopia. (Nintendo Entertainment System)"
PKG_LONGDESC="This project is a fork of the original Nestopia source code, plus the Linux port. The purpose of the project is to enhance the original, and ensure it continues to work on modern operating systems."

PKG_IS_ADDON="no"
PKG_TOOLCHAIN="make"
PKG_AUTORECONF="no"
PKG_USE_CMAKE="no"

GET_HANDLER_SUPPORT="git"

pre_configure_target() {
cp -f $PKG_BUILD/NstCore.hpp $PKG_BUILD/source/core/NstCore.hpp
}

make_target() {
  cd $PKG_BUILD
  make -C libretro
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp $PKG_BUILD/skin.png $INSTALL/usr/lib/libretro/
  cp $PKG_BUILD/skin.png $INSTALL/etc/
  cp libretro/nestopiaCV_libretro.so $INSTALL/usr/lib/libretro/
echo 'display_name = "Nintendo - NES / Famicom (Nestopia CV)"
authors = "Martin Freij|R. Belmont|R. Danbrook"
supported_extensions = "nes|fds|unf|unif"
corename = "NestopiaCV"
manufacturer = "Nintendo"
categories = "Emulator"
systemname = "Nintendo Entertainment System"
systemid = "nes"
database = "Nintendo - Nintendo Entertainment System|Nintendo - Family Computer Disk System"
license = "GPLv2"
permissions = ""
display_version = "v1.47-WIP"
supports_no_game = "false"
firmware_count = 2
firmware0_desc = "NstDatabase.xml (Nestopia UE Database file)"
firmware0_path = "NstDatabase.xml"
firmware0_opt = "false"
firmware1_desc = "disksys.rom (Family Computer Disk System BIOS)"
firmware1_path = "disksys.rom"
firmware1_opt = "false"
notes = "Get NstDatabase.xml from https://github.com/0ldsk00l/nestopia|(!) disksys.rom (md5): ca30b50f880eb660a320674ed365ef7a|Press Retropad L1 to switch disk side."'>  $INSTALL/usr/lib/libretro/nestopiaCV_libretro.info

}
