# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="soniccd"
PKG_VERSION="129cd86fbd0d6af58ae50f9c111021f0b4ef4f9c"
PKG_ARCH="any"
PKG_SITE="https://github.com/Rubberduckycooly/Sonic-CD-11-Decompilation"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2-git libtheora"
PKG_SHORTDESC="A Full Decompilation of Sonic CD 2011"
PKG_TOOLCHAIN="make"

pre_configure_target() {
# Add missing -lstdc++fs
sed -i "s|pthread|pthread -lstdc++fs|" $PKG_BUILD/Makefile
}

makeinstall_target() {
mkdir -p $INSTALL/usr/bin
cp bin/soniccd $INSTALL/usr/bin

mkdir -p $INSTALL/usr/config/emuelec/configs/sonic
cp $PKG_DIR/config/* $INSTALL/usr/config/emuelec/configs/sonic
} 
