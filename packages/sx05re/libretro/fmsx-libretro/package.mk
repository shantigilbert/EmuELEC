# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="fmsx-libretro"
PKG_VERSION="1806eed4376fbe2fad82fa19271ea298cfbb7795"
PKG_SHA256="c892758f6a6454698c4c4104b50e33ee6ad896b856d9eef4d9cf73060d2a902d"
PKG_ARCH="any"
PKG_LICENSE="OPEN/NON-COMMERCIAL"
PKG_SITE="https://github.com/libretro/fmsx-libretro"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="Port of fMSX to the libretro API. "
PKG_TOOLCHAIN="make"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp fmsx_libretro.so ${INSTALL}/usr/lib/libretro/
}
