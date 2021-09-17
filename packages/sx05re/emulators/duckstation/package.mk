# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="duckstation"
PKG_VERSION="4a017bd1"
PKG_SHA256="5c0563c1ca68b099c3936097f132a737ad6e270a90198743e45acc3f1cbd8830"
PKG_LICENSE="NON-COMMERCIAL"
PKG_ARCH="aarch64"
PKG_SITE="https://www.duckstation.org/libretro"
PKG_URL="${PKG_SITE}/duckstation_libretro_linux_aarch64.zip"
PKG_SHORTDESC="Fast PlayStation 1 emulator for PC and Android "
PKG_TOOLCHAIN="manual"

pre_unpack() {
	unzip sources/duckstation/duckstation-${PKG_VERSION}.zip -d $PKG_BUILD
}

makeinstall_target() {
	mkdir -p $INSTALL/usr/lib/libretro
	cp $PKG_BUILD/duckstation_libretro.so $INSTALL/usr/lib/libretro
}
