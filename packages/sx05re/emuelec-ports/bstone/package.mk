# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="bstone"
PKG_VERSION="66323cab3afe35ad67ca24b19cae0ea5f2b11d85"
PKG_VERSION="a92fe65125cd18bf555a035f9ca094f215460671"
PKG_ARCH="any"
PKG_SITE="https://github.com/bibendovsky/bstone"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2-git"
PKG_SHORTDESC="Unofficial source port for Blake Stone series "
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET=" -DCMAKE_BUILD_TYPE=Release"

makeinstall_target() {
mkdir -p $INSTALL/usr/bin
cp -rf ${PKG_BUILD}/.${TARGET_NAME}/src/bstone $INSTALL/usr/bin/bstone
} 
