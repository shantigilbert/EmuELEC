# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="swanstation"
PKG_VERSION="7a27436548128c00e70b08dde63c52118e2a6228"
PKG_SHA256="ffa002c99072778acfb6780a6dae46e3566f0c0d9e9d737b458a526a0457d7ba"
PKG_ARCH="aarch64"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/swanstation"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain nasm:host ${OPENGLES}"
PKG_SECTION="libretro"
PKG_SHORTDESC="Fast PlayStation 1 emulator for PC and Android"
PKG_TOOLCHAIN="cmake"
PKG_BUILD_FLAGS="-lto"

pre_configure_target() {
 PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release -DBUILD_LIBRETRO_CORE=ON "
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/.${TARGET_NAME}/swanstation_libretro.so ${INSTALL}/usr/lib/libretro/
}
