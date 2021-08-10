# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="potator"
PKG_VERSION="f40c6d99f5a4e98f1ae088f98f631cb33da8c056"
PKG_SHA256="18e1c53905855f3ecc4a121fe3208b77ae1e960cb52d04b1cf200d126802867d"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="The Unlicense"
PKG_SITE="https://github.com/libretro/potator"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_LONGDESC="A Watara Supervision Emulator based on Normmatt version "
PKG_TOOLCHAIN="make"

make_target() {
cd $PKG_BUILD/platform/libretro
make
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp $PKG_BUILD/platform/libretro/potator_libretro.so $INSTALL/usr/lib/libretro/potator_libretro.so
}
