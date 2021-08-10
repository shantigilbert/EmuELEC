# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="sundog"
PKG_VERSION="eb48447d1791e8bbd9ce4afe872a541dc67fcca1"
PKG_SHA256="422a8d49cec74214aab6ea1f856e4e954bab26d33914722cfd1d9734ed47df4c"
PKG_ARCH="any"
PKG_SITE="https://github.com/laanwj/sundog"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2-git"
PKG_LONGDESC="A port of the Atari ST game SunDog: Frozen Legacy (1984) by FTL software "
PKG_TOOLCHAIN="make"

pre_configure_target() {
  cd src
  PKG_MAKE_OPTS_TARGET=" -C ${PKG_BUILD}/src sundog"
  sed -i "s|sdl2-config|$SYSROOT_PREFIX/usr/bin/sdl2-config|g" Makefile
  sed -i "s|-lreadline|-lreadline -lncurses|g" Makefile
}

makeinstall_target() {
	mkdir -p $INSTALL/usr/bin
	cp ${PKG_BUILD}/src/sundog $INSTALL/usr/bin
}
