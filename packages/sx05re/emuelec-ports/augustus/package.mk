# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="augustus"
PKG_VERSION="482f4ff544148c538460d6592bbff450dc391316"
PKG_SHA256="ee0cbb543a2a5e26131b26e39dd8f6aaf88223dfcf58aca2b302348fd063cc48"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/Keriew/augustus"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="An open source re-implementation of Caesar III"
PKG_TOOLCHAIN="cmake-make"

pre_configure_target() {
# Just setting the version
sed -i "s|unknown development version|Version: ${PKG_VERSION:0:7} - ${DISTRO}|g" ${PKG_BUILD}/CMakeLists.txt
}
