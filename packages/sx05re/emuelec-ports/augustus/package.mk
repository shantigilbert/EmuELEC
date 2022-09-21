# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="augustus"
PKG_VERSION="3f302fb4dd2d9edd2f89c6d709723123802f0eec"
PKG_SHA256="6b5fa4675054325aa1a1afe9408257d69d9fb183f19d7743fc9422f392b35812"
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
