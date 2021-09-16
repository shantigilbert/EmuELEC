# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="droidports"
PKG_VERSION="cb860d6d38e9251cc38837a538a4d77f894a31c1"
PKG_ARCH="arm"
PKG_SITE="https://github.com/JohnnyonFlame/droidports"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2-git SDL2_image openal-soft bzip2 libzip libpng"
PKG_LONGDESC="A repository for experimenting with elf loading and in-place patching of android native libraries on non-android operating systems."
PKG_TOOLCHAIN="cmake"

pre_configure_target() {
	PKG_CMAKE_OPTS_TARGET=" -DCMAKE_BUILD_TYPE=Release -DPLATFORM=linux -DPORT=gmloader -DUSE_BUILTIN_FREETYPE=ON"
}

makeinstall_target() {
	mkdir -p $INSTALL/usr/bin
	cp ${PKG_BUILD}/.${TARGET_NAME}/gmloader $INSTALL/usr/bin
	cp $PKG_DIR/scripts/* $INSTALL/usr/bin
}
