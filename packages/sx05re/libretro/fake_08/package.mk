# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="fake_08"
PKG_VERSION="49f4eb1bd465639d36ef6657e038da892399c7d9"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/jtothebell/fake-08"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="A Pico-8 player/emulator for console homebrew"

pre_configure_target() {
	PKG_MAKE_OPTS_TARGET="-C ${PKG_BUILD}/platform/libretro"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -v ${PKG_BUILD}/platform/libretro/fake08_libretro.so ${INSTALL}/usr/lib/libretro/
}
