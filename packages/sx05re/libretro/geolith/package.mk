# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present EmuELEC (https://github.com/emuelec)

PKG_NAME="geolith"
PKG_VERSION="4d9692a48bbb375556527bd1aade29b1de9e497e"
PKG_SHA256="27e8d505464cdfdc36b94f1835b7c8f30ad35c83bd00f0fbe00415a85a8981fc"
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
