# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present EmuELEC (https://github.com/emuelec)

PKG_NAME="geolith"
PKG_VERSION="e90bd373f361aa11b4e00e1841ddb384317921d6"
PKG_SHA256="e4ee16121642c4b5d30e90366c7667a07f658945afc5b50f42c26470adfd7bad"
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
