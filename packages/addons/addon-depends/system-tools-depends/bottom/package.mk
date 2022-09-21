# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="bottom"
PKG_VERSION="0.6.8"
PKG_SHA256="4e4eb251972a7af8c46dd36bcf1335fea334fb670569434fbfd594208905b2d9"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/ClementTsang/bottom"
PKG_URL="https://github.com/ClementTsang/bottom/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain cargo:host"
PKG_LONGDESC="A TUI system monitor written in Rust."
PKG_TOOLCHAIN="manual"

make_target() {
  cargo build \
    --target ${TARGET_NAME} \
    --release \
    --locked \
    --all-features
}

makeinstall_target() {
  mkdir -p ${INSTALL}
  cp ${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/release/btm ${INSTALL}
}
