# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="game.libretro.scummvm"
PKG_VERSION="2.1.1.23-Matrix"
PKG_SHA256="2d8e4d553d563c6fe46ac501ae899a940b4109be2fc21a0b303b1ba7e275dd1c"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/kodi-game/game.libretro.scummvm"
PKG_URL="https://github.com/kodi-game/game.libretro.scummvm/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform libretro-scummvm"
PKG_SECTION=""
PKG_LONGDESC="game.libretro.scummvm: scummvm for Kodi"

PKG_IS_ADDON="yes"
PKG_ADDON_TYPE="kodi.gameclient"

pre_configure_target() {
  export LDFLAGS=$(echo ${LDFLAGS} | sed -e "s|-Wl,--as-needed||")
}
