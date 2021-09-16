# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="tic-80"
PKG_VERSION="074936c04692c8dd8003b6bc6ccd2298d83d0c8b"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/nesbox/TIC-80"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain tic-80:host"
PKG_LONGDESC="TIC-80 is a fantasy computer for making, playing and sharing tiny games."
GET_HANDLER_SUPPORT="git"

PKG_CMAKE_OPTS_TARGET="-DBUILD_LIBRETRO=ON \
					   -DBUILD_PLAYER=ON \
					   -DBUILD_DEMO_CARTS=OFF \
                       -DBUILD_SOKOL=OFF \
                       -DBUILD_SDL=ON"

PKG_CMAKE_OPTS_HOST="-DBUILD_LIBRETRO=OFF \
					   -DBUILD_PLAYER=OFF \
					   -DBUILD_DEMO_CARTS=ON \
                       -DBUILD_SOKOL=OFF \
                       -DBUILD_SDL=OFF"

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp $PKG_BUILD/.$TARGET_NAME/lib/tic80_libretro.so $INSTALL/usr/lib/libretro/tic80_libretro.so
}
