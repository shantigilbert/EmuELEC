# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="supertuxkart"
PKG_VERSION="f9fa9a764b115b3674eb3c0e6333650b4447b022"
PKG_SHA256="ada0b53d097d235d4ec7edfec4b31a318a2b655a4a2f1403c4464298d613d778"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/supertuxkart/stk-code"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2-git harfbuzz"
PKG_LONGDESC="SuperTuxKart is a free kart racing game. It focuses on fun and not on realistic kart physics. Instructions can be found on the in-game help page."

pre_configure_target() {
PKG_CMAKE_OPTS_TARGET+=" -DUSE_WIIUSE=OFF -DCHECK_ASSETS=off -DCMAKE_BUILD_TYPE=Release"
}

makeinstall_target() {
mkdir -p $INSTALL/usr/bin
cp $PKG_BUILD/.${TARGET_NAME}/bin/supertuxkart $INSTALL/usr/bin/
cp $PKG_DIR/scripts/* $INSTALL/usr/bin
}
