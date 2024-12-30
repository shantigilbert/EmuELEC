# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present EmuELEC (https://github.com/emuelec)

PKG_NAME="geolith"
PKG_VERSION="38f749148b196531b36e7096c0609d9c00429168"
PKG_SHA256="75257b8c7f6e7655ca57cae9b30f851323011368aea6af898ce57e9170ef2f82"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/geolith-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Highly accurate emulator for the Neo Geo AES and MVS Cartridge Systems"
PKG_TOOLCHAIN="make"

make_target() {
cd libretro
  make -f ./Makefile platform=rpi3_64
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp geolith_libretro.so ${INSTALL}/usr/lib/libretro/
}
