# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="sonicmania"
PKG_VERSION="e74c0005fba8ffcfd150205beef73a954222d38b"
PKG_ARCH="any"
PKG_SITE="https://github.com/Rubberduckycooly/Sonic-Mania-Decompilation"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_SHORTDESC="Sonic Mania Decompilation"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-gold"

pre_configure_target() {
PKG_MAKE_OPTS_TARGET=" STATIC=0 DEBUG=0"
cd ${PKG_BUILD}

# There is a space on the Makefile that will result in an error *** missing separator. Stop
sed -i "s| 	\$(STRIP) \$@|	\$(STRIP) \$@|" ${PKG_BUILD}/Makefile
}

make_target(){
cd ${PKG_BUILD}/dependencies/RSDKv5
make PLATFORM=Linux SUBSYSTEM=SDL2

cd ${PKG_BUILD}
make ${PKG_MAKE_OPTS_TARGET}
}

makeinstall_target() {
mkdir -p $INSTALL/usr/bin/sonic_mania
cp dependencies/RSDKv5/bin/Linux/SDL2/RSDKv5 $INSTALL/usr/bin/sonicmania
cp dependencies/RSDKv5/bin/Linux/SDL2/Game.so $INSTALL/usr/bin/sonic_mania/Game.so

mkdir -p $INSTALL/usr/config/emuelec/configs/sonicmania
cp $PKG_DIR/config/* $INSTALL/usr/config/emuelec/configs/sonicmania
} 
