# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="rtkbt-firmware-aml"
PKG_VERSION="763c7195bb0328b45a5679e212ab05150361cc3a"
PKG_SHA256="2996dd867990a14b8d431c789285363ff35f4f2304ce8c92db401122ec43db9a"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/rtkbt-firmware-aml"
PKG_URL="https://github.com/CoreELEC/rtkbt-firmware-aml/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain rtk_hciattach"
PKG_LONGDESC="Realtek BT Linux firmware"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  FWDIR=$INSTALL/$(get_full_firmware_dir)/rtlbt

  mkdir -p $FWDIR
    cp -a $PKG_BUILD/* $FWDIR
}
