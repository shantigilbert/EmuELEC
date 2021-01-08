# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Nikolai Wuttke (https://github.com/lethal-guitar)

PKG_NAME="rigelengine"
PKG_VERSION="3106f6078757c8d7a772a378841ffe598c81f014"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/lethal-guitar/RigelEngine"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2-git SDL2_mixer boost"
PKG_LONGDESC="A modern re-implementation of the classic DOS game Duke Nukem II"
PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=Release -DUSE_GL_ES=ON -DWARNINGS_AS_ERRORS=OFF"
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="cmake"

pre_configure_target() {
  git submodule update --init --recursive
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/config/emuelec/bin
  cp ./src/RigelEngine $INSTALL/usr/config/emuelec/bin
}
