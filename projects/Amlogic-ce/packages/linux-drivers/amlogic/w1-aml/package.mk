# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="w1-aml"
PKG_VERSION="d451f7461891bd7ba54c146b411c1cf9fee64279"
PKG_SHA256="5e47f1f447e83543bb146710a4f467452567c48085409b1c4bc9a124d2eaa0cb"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/w1-aml"
PKG_URL="https://github.com/CoreELEC/w1-aml/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="Amlogic W150S1 Linux driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}/project_w1/vmac \
    subdir-ccflags-y="-mno-outline-atomics"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    find ${PKG_BUILD}/project_w1/vmac/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;

  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/w1
    cp ${PKG_BUILD}/project_w1/vmac/aml_wifi*.txt ${INSTALL}/$(get_full_firmware_dir)/w1
}
