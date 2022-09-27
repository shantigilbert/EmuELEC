# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="rtk_hciattach"
PKG_VERSION="58820c428d2ecae6aaf5e4f00997652b9479853a"
PKG_SHA256="20161cf3011f57dc9912db7270be1a83e543a61ea8757c23eaf983542fb021e0"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/Caesar-github/rkwifibt"
PKG_URL="https://github.com/Caesar-github/rkwifibt/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Realtek BT FW loader"
PKG_TOOLCHAIN="make"

unpack() {
  mkdir -p $PKG_BUILD
  tar --strip-components=3 -xf $SOURCES/$PKG_NAME/$PKG_NAME-$PKG_VERSION.tar.gz -C $PKG_BUILD rkwifibt-$PKG_VERSION/realtek/rtk_hciattach
}
