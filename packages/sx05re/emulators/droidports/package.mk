# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="droidports"
PKG_VERSION="d044d90d81927d175018396d673fb4ff077aebb3"
PKG_ARCH="arm"
PKG_SITE="https://github.com/JohnnyonFlame/droidports"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_image openal-soft bzip2 libzip libpng"
PKG_LONGDESC="A repository for experimenting with elf loading and in-place patching of android native libraries on non-android operating systems."
PKG_TOOLCHAIN="cmake"

pre_configure_target() {
# Just a small workaround for GCC 11 until upstream is fixed
sed -i "s|usleep|usleep2|g" ${PKG_BUILD}/bridges/misc_bridges.c

	PKG_CMAKE_OPTS_TARGET=" -DCMAKE_BUILD_TYPE=Release -DPLATFORM=linux -DPORT=gmloader -DUSE_BUILTIN_FREETYPE=ON"
}

makeinstall_target() {
	mkdir -p $INSTALL/usr/bin
	cp ${PKG_BUILD}/.${TARGET_NAME}/gmloader $INSTALL/usr/bin
	cp $PKG_DIR/scripts/* $INSTALL/usr/bin
}
