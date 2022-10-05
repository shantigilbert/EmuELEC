# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="potator"
PKG_VERSION="06ec3b724b6fccda6805e3baa76c00c3bc024f23"
PKG_SHA256="7ee98dc0726118a123b820a0149bb6a24ecb5e73e95ae2b76bdee7de9200f108"
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
