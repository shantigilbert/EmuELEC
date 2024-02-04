# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="xow"
PKG_VERSION="d335d6024f8380f52767a7de67727d9b2f867871"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/medusalix/xow"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Linux driver for the Xbox One wireless dongle  "
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET=" BUILD=RELEASE"

pre_configure_target() {
sed -i "s|ld -r|\$(LD) -r|" Makefile

}
makeinstall_target() {
mkdir -p $INSTALL/usr/bin
cp xow $INSTALL/usr/bin
}
