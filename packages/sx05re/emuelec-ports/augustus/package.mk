# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="augustus"
PKG_VERSION="178ef26e364cafd794c5f2bd41e191850889e1a1"
PKG_SHA256="d874d450d36deb3f054bc36a4a8bb728a00ad255531aa36dcbe8a78b1babab4b"
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
