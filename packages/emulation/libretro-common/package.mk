# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libretro-common"
PKG_VERSION="bf52f8b95392e5149f27f31b001c79b8f1f7f579"
PKG_SHA256="bf7b8bdec8b35b33ab1d069d94087e9bc648db2e896789590878cd278458ceb7"
PKG_LICENSE="Public domain"
PKG_SITE="https://github.com/libretro/libretro-common"
PKG_URL="https://github.com/libretro/libretro-common/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Reusable coding blocks useful for libretro core and frontend development"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p "${SYSROOT_PREFIX}/usr/include/${PKG_NAME}"
  cp -pR ${PKG_BUILD}/include/* "${SYSROOT_PREFIX}/usr/include/${PKG_NAME}/"
}
