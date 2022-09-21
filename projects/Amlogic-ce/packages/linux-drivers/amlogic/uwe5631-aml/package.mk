# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="uwe5631-aml"
PKG_VERSION="93f9f70b063f0bf2cbdf12addf80a49c406ff276"
PKG_SHA256="904e3ad342870c98139aed60d0638b74f2be9fc7a0c8d4d791574a374cf837d7"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/uwe5631-aml"
PKG_URL="https://github.com/CoreELEC/uwe5631-aml/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="uwe5631-aml: Unisoc UWE5621 WIFI/BT driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

make_target() {
  echo "making WIFI"
  kernel_make -C ${PKG_BUILD} \
    M=${PKG_BUILD} \
    KERNEL_SRC=$(kernel_path) \
    EXTRA_CFLAGS="-fno-pic -Wno-sizeof-pointer-memaccess -Wno-declaration-after-statement -I${PKG_BUILD}/BSP/include -DCUSTOMIZE_WIFI_CFG_PATH=\\\"/lib/firmware/unisoc\\\"" \
    modules

  echo "making BT"
  kernel_make -C ${PKG_BUILD}/BT/tty-sdio \
    M=${PKG_BUILD}/BT/tty-sdio \
    KERNEL_SRC=$(kernel_path) \
    CURFOLDER=${PKG_BUILD}/BSP \
    modules
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}

  find $PKG_BUILD/ -name \*.ko -not -path '*/\.*' \
    -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;

  mkdir -p ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/unisoc
  cp -av ${PKG_DIR}/firmware/* ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/unisoc
}
