# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="falloutce1"
PKG_VERSION="6be823cf7c614a693aca3ab6a4a8aa1df2537793"
PKG_REV="1"
PKG_ARCH="any"
PKG_SITE="https://github.com/alexbatalov/fallout1-ce"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="Game port of Fallout using SDL2"
PKG_TOOLCHAIN="cmake"
GET_HANDLER_SUPPORT="git"

makeinstall_target() {
mkdir -p $INSTALL/usr/bin
cp $PKG_BUILD/.${TARGET_NAME}/fallout-ce $INSTALL/usr/bin
cp -rf $PKG_DIR/scripts/* $INSTALL/usr/bin
mkdir -p $INSTALL/usr/config/emuelec/configs/falloutce1
cp $PKG_DIR/config/* $INSTALL/usr/config/emuelec/configs/falloutce1
}
