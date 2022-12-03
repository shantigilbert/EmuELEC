# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="supertuxkart"
PKG_VERSION="7702da596518646c58c2b024033233b04f5fc6da"
PKG_SHA256="3436ecaf027a469f63317f770e48ebe68dfd05203ecc447dd486c52782e5cdc8"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/supertuxkart/stk-code"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 harfbuzz"
PKG_LONGDESC="SuperTuxKart is a free kart racing game. It focuses on fun and not on realistic kart physics. Instructions can be found on the in-game help page."

pre_configure_target() {
PKG_CMAKE_OPTS_TARGET+=" -DBUILD_RECORDER=0 -DUSE_WIIUSE=OFF -DCHECK_ASSETS=off -DCMAKE_BUILD_TYPE=Release"
}

makeinstall_target() {
mkdir -p $INSTALL/usr/bin
cp $PKG_BUILD/.${TARGET_NAME}/bin/supertuxkart $INSTALL/usr/bin/
cp $PKG_DIR/scripts/* $INSTALL/usr/bin
}
