# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="soniccd"
PKG_VERSION="aea302ed5dc4a5bf82bad04594c51e9be3ed6f59"
PKG_ARCH="any"
PKG_SITE="https://github.com/Rubberduckycooly/Sonic-CD-11-Decompilation"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2 libtheora"
PKG_SHORTDESC="A Full Decompilation of Sonic CD 2011"
PKG_TOOLCHAIN="cmake"
PKG_EE_UPDATE="no"

pre_configure_target() {
PKG_CMAKE_OPTS_TARGET="-DRETRO_SDL_VERSION=2 -DRETRO_USE_HW_RENDER=OFF"
}

makeinstall_target() {
mkdir -p $INSTALL/usr/bin
cp  $PKG_BUILD/.${TARGET_NAME}/RSDKv3 $INSTALL/usr/bin/soniccd

mkdir -p $INSTALL/usr/config/emuelec/configs/sonic
cp $PKG_DIR/config/* $INSTALL/usr/config/emuelec/configs/sonic
} 
