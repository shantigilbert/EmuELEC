# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="fmsx-libretro"
PKG_VERSION="34e14bee33c3ed20ee637d96d294fc1a385e3702"
PKG_SHA256="1ee5576e90b1de83e82511c7e4a0d17ea16f79b6fa613a9b195cb783a2103c44"
PKG_ARCH="any"
PKG_LICENSE="OPEN/NON-COMMERCIAL"
PKG_SITE="https://github.com/libretro/fmsx-libretro"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="Port of fMSX to the libretro API. "
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp fmsx_libretro.so $INSTALL/usr/lib/libretro/
}
