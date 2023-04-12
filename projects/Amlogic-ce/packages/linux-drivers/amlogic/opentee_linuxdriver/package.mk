# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="opentee_linuxdriver"
PKG_VERSION="3108eb27eb23937c4bc7a0a05e72e2aaf1ae6800"
PKG_SHA256="abafdbe20673635289edbc3c93d903dc7752a52d8a8f78582a738ec09b929ee0"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/opentee_linuxdriver"
PKG_URL="https://github.com/CoreELEC/opentee_linuxdriver/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_LONGDESC="OP-TEE Linux Driver"
PKG_IS_KERNEL_PKG="yes"

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    find ${PKG_BUILD}/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;
}

post_install() {
  enable_service opentee_linuxdriver.service
}
