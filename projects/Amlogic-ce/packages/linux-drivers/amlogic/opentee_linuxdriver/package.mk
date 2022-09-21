# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="opentee_linuxdriver"
PKG_VERSION="423100e389fafd31da16530594c1b6171857d58c"
PKG_SHA256="bf382a4e698215458ec1dfb5a44eea2ce2644552772c1c0efb1b716639c1d7e2"
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
