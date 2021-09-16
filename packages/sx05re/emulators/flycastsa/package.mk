# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="flycastsa"
PKG_VERSION="4d5c93adfa538b7d23d734ccf160afd91c6bf54d"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/flyinghead/flycast"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain $OPENGLES alsa SDL2-git libzip zip"
PKG_LONGDESC="Flycast is a multiplatform Sega Dreamcast, Naomi and Atomiswave emulator"
PKG_TOOLCHAIN="cmake"
PKG_GIT_CLONE_BRANCH="libretro"


if [ "${ARCH}" == "arm" ]; then
	PKG_PATCH_DIRS="arm"
fi
pre_configure_target() {
PKG_CMAKE_OPTS_TARGET+="-DUSE_GLES=ON -DUSE_VULKAN=OFF"
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/bin
  cp $PKG_BUILD/.${TARGET_NAME}/flycast $INSTALL/usr/bin/flycast
  cp $PKG_DIR/scripts/* $INSTALL/usr/bin
}
