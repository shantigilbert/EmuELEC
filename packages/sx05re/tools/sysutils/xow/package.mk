# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="xow"
PKG_VERSION="9e86c529afab1ffde40e2554e5eee1ecfcbf8c7a"
PKG_SHA256="6112e8a0f9246dec746beb11f191f89b7078dcba2b7f1460b628e031b3b1fd33"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/medusalix/xow"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Linux driver for the Xbox One wireless dongle  "
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET=" BUILD=RELEASE"

pre_configure_target() {
sed -i "s|ld -r|\$(LD) -r|" Makefile

}
makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp xow ${INSTALL}/usr/bin
}
