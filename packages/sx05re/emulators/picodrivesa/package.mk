# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="picodrivesa"
PKG_VERSION="2ec448a8ce6b0d929ba43748462109e46ca0bed4"
PKG_REV="1"
PKG_LICENSE="GPL2"
PKG_SITE="https://github.com/irixxxx/picodrive"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="A multi-platform Atari 2600 Emulator"
PKG_TOOLCHAIN="configure"
GET_HANDLER_SUPPORT="git"

pre_configure_target() { 
TARGET_CONFIGURE_OPTS=" --platform=generic"
cd $PKG_BUILD
git submodule update --init
}

#make_target() {
#cd $PKG_BUILD
#mv $PKG_BUILD/.${TARGET_NAME}/* $PKG_BUILD
#make 
#}

makeinstall_target() {
mkdir -p $INSTALL/usr/bin/skin
cp -rf $PKG_BUILD/PicoDrive $INSTALL/usr/bin
cp -rf $PKG_BUILD/skin/* $INSTALL/usr/bin/skin/
}
