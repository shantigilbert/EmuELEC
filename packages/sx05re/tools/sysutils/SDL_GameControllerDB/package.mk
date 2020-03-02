# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="SDL_GameControllerDB"
PKG_VERSION="c5992e0edc141be1fd0764c810792b4ead26e25c"
PKG_SHA256="8e86c7b05d442b114f150d96958d7e310b28b9bb0b802bc54d0fad26ddcbc2af"
PKG_LICENSE="OSS"
#PKG_SITE="https://github.com/gabomdq/SDL_GameControllerDB"
PKG_SITE="https://github.com/gabomdq/gamecontrollerdb"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET=""
PKG_LONGDESC="A community sourced database of game controller mappings to be used with SDL2 Game Controller functionality"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p $INSTALL/usr/config/SDL-GameControllerDB
  #add other controllers
  cat $PKG_DIR/extra_gamepads/emuelec_gamepads.txt >> $PKG_BUILD/gamecontrollerdb.txt
  cp $PKG_BUILD/gamecontrollerdb.txt $INSTALL/usr/config/SDL-GameControllerDB
}
