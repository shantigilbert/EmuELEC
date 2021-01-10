# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="duckstation"
PKG_VERSION="b3bf9f3f10d86078fd69e060e3d98c80b6cde4cd"
PKG_SHA256="f342f3a24f86a73d91a03beef015abd4852e792706b6984f774f9d35194d0d4a"
PKG_ARCH="aarch64"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/stenzek/duckstation"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain nasm:host $OPENGLES"
PKG_SECTION="libretro"
PKG_SHORTDESC="DuckStation - PlayStation 1, aka. PSX Emulator"
PKG_TOOLCHAIN="cmake"
PKG_BUILD_FLAGS="-lto"

pre_configure_target() {
# PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release -DBUILD_LIBRETRO_CORE=ON "
 PKG_CMAKE_OPTS_TARGET+=" -DBUILD_LIBRETRO_CORE=ON -DBUILD_QT_FRONTEND=OFF -DBUILD_SDL_FRONTEND=OFF -DCMAKE_BUILD_TYPE=Release -DENABLE_DISCORD_PRESENCE=OFF -DUSE_SDL=OFF -DUSE_EGL=OFF -DUSE_X11=OFF -DUSE_WAYLAND=OFF"
 sed -i ../src/duckstation-libretro/libretro_host_interface.cpp -e 's/   "OpenGL"/   "Software"/'
 sed -i ../src/duckstation-libretro/libretro_host_interface.cpp -e 's/   "Info"}/   "None"}/'
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp $PKG_BUILD/.$TARGET_NAME/duckstation_libretro.so $INSTALL/usr/lib/libretro/
}
