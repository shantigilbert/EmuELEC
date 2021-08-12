# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="sonic2013"
PKG_VERSION="c3be493616ada254f52dfd1f0842df1de5704c3c"
PKG_ARCH="any"
PKG_SITE="https://github.com/Rubberduckycooly/Sonic-1-2-2013-Decompilation"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2-git"
PKG_SHORTDESC="Sonic 1/2 (2013) Decompilation"
PKG_TOOLCHAIN="make"

pre_configure_target() {
# Add missing -lstdc++fs
sed -i "s|pthread|pthread -lstdc++fs|" $PKG_BUILD/Makefile
}

makeinstall_target() {
mkdir -p $INSTALL/usr/bin
cp bin/RSDKv4 $INSTALL/usr/bin/sonic2013

mkdir -p $INSTALL/usr/config/emuelec/configs/sonic
cp $PKG_DIR/config/* $INSTALL/usr/config/emuelec/configs/sonic
} 
