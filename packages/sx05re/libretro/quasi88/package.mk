# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present asakous (https://github.com/asakous)

PKG_NAME="quasi88"
PKG_VERSION="e3d06c4f34c3643d3ea9248a47cdc6cf60c1e0b1"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="BSD3"
PKG_SITE="https://github.com/libretro/quasi88-libretro"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="A port of QUASI88, a PC-8800 series emulator by Showzoh Fukunaga, to the libretro API"
PKG_LONGDESC="A port of QUASI88, a PC-8800 series emulator by Showzoh Fukunaga, to the libretro API"
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp quasi88_libretro.so $INSTALL/usr/lib/libretro/
}
