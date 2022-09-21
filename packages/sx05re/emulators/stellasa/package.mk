# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="stellasa"
PKG_VERSION="4fecd8fc97ab7786610a5ae4e665e4fe4d5d1374"
PKG_SHA256="1107c815d1ff1779202d78ff3b89cf643185274a8acbbdbe2c4115e8db74bb29"
PKG_REV="1"
PKG_LICENSE="GPL2"
PKG_SITE="https://github.com/stella-emu/stella"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_SHORTDESC="A multi-platform Atari 2600 Emulator"
PKG_TOOLCHAIN="configure"

pre_configure_target() { 
TARGET_CONFIGURE_OPTS="--host=${TARGET_NAME} --with-sdl-prefix=${SYSROOT_PREFIX}/usr/bin --disable-windowed"
}

make_target() {
cd $PKG_BUILD
mv $PKG_BUILD/.${TARGET_NAME}/* $PKG_BUILD
make 
}

makeinstall_target() {
mkdir -p $INSTALL/usr/bin
cp -rf $PKG_BUILD/stella $INSTALL/usr/bin
cp -rf $PKG_DIR/scripts/* $INSTALL/usr/bin
}
