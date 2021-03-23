# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="lzdoom"
PKG_VERSION="c4de21c3caee1a53720c60cbee47d80db87b086a"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/christianhaitian/lzdoom"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2-git lzdoom:host"
PKG_SHORTDESC="LZDoom"
PKG_LONGDESC="ZDoom is a family of enhanced ports of the Doom engine for running on modern operating systems. It runs on Windows, Linux, and OS X, and adds new features not found in the games as originally published by id Software."
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="cmake-make"

pre_build_host() {
HOST_CMAKE_OPTS=""
}

make_host() {
  cmake . -DNO_GTK=ON
  make
}

makeinstall_host() {
: #no
}

pre_configure_target() {
PKG_CMAKE_OPTS_TARGET=" -DNO_GTK=ON \
                        -DFORCE_CROSSCOMPILE=ON \
                        -DIMPORT_EXECUTABLES=$PKG_BUILD/.$HOST_NAME/ImportExecutables.cmake
                        -DCMAKE_BUILD_TYPE=Release"
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/bin
  cd $PKG_BUILD
  cp .$TARGET_NAME/lzdoom $INSTALL/usr/bin

  mkdir -p $INSTALL/usr/config/emuelec/configs/lzdoom
  cp $PKG_DIR/config/* $INSTALL/usr/config/emuelec/configs/lzdoom
  cp .$TARGET_NAME/*.pk3 $INSTALL/usr/config/emuelec/configs/lzdoom
  cp -r .$TARGET_NAME/soundfonts $INSTALL/usr/config/emuelec/configs/lzdoom

  mkdir -p $INSTALL/usr/bin
  cp $PKG_DIR/scripts/*  $INSTALL/usr/bin
}

