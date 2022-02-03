# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)
#https://github.com/MaximLopez/HeartOfDarkness-SDL"

PKG_NAME="hodesdl"
PKG_VERSION="a971e54d53ac8c8e94894139d5b89c81d04b4d63"
PKG_REV="1"
PKG_ARCH="any"
PKG_SITE="https://github.com/usineur/hode"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="Game port of 'Heart of Darkness' using SDL2"
PKG_TOOLCHAIN="cmake"
GET_HANDLER_SUPPORT="git"

makeinstall_target() {
mkdir -p $INSTALL/usr/bin
cp $PKG_BUILD/.${TARGET_NAME}/hode $INSTALL/usr/bin
cp $PKG_BUILD/hode.ini $INSTALL/usr/bin
}
