# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="brcmfmac_sdio-firmware-rpi"
PKG_VERSION="b4fa91541cd713c721fadf0720e2655db42cc179"
PKG_SHA256="50a834871457fe2c34c4da29e189a00801552bc90a8039a3e87378629a0dbc4c"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/LibreELEC/LibreELEC.tv"
PKG_URL="https://github.com/LibreELEC/${PKG_NAME}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Firmware for brcm bluetooth chips used on RaspberryPi devices."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  DESTDIR=${INSTALL}/$(get_kernel_overlay_dir) ./install
}

post_makeinstall_target() {
  # Install rpi btuart script to bring up Bluetooth
  mkdir -p ${INSTALL}/usr/bin
    cp -P ${PKG_DIR}/scripts/rpi-btuart ${INSTALL}/usr/bin
    cp -P ${PKG_DIR}/scripts/rpi-udev ${INSTALL}/usr/bin
}

post_install() {
  enable_service brcmfmac_sdio-firmware.service
}
