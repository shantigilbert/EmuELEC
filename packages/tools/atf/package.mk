# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC

PKG_NAME="atf"
PKG_VERSION="2.7"
PKG_SHA256="327c65b1bc231608a7a808b068b00c1a22310e9fc86158813cd10a9711d5725e"
PKG_ARCH="arm aarch64"
PKG_LICENSE="BSD-3c"
PKG_SITE="https://github.com/ARM-software/arm-trusted-firmware"
PKG_URL="https://github.com/ARM-software/arm-trusted-firmware/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ARM Trusted Firmware is a reference implementation of secure world software, including a Secure Monitor executing at Exception Level 3 and various Arm interface standards."
PKG_TOOLCHAIN="manual"

[ -n "${KERNEL_TOOLCHAIN}" ] && PKG_DEPENDS_TARGET+=" gcc-${KERNEL_TOOLCHAIN}:host"

make_target() {
  if [ "${DEVICE}" = "iMX8" ]; then
    CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="--no-warn-rwx-segments" CFLAGS="--param=min-pagesize=0" make PLAT=${ATF_PLATFORM} bl31
  else
    CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="--no-warn-rwx-segments" CFLAGS="" make PLAT=${ATF_PLATFORM} bl31
  fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader
  cp -a build/${ATF_PLATFORM}/release/bl31.bin ${INSTALL}/usr/share/bootloader
}
