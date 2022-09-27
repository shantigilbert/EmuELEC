# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="estouchy"
PKG_VERSION="1.0"
PKG_REV="101"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://www.kodi.tv"
PKG_URL=""
PKG_DEPENDS_TARGET="kodi"
PKG_SECTION="skin"
PKG_SHORTDESC="Kodi skin Estouchy"
PKG_LONGDESC="Kodi skin Estouchy"
PKG_TOOLCHAIN="manual"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Estouchy"
PKG_ADDON_TYPE="xbmc.gui.skin"

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}
    cp -a $(get_install_dir kodi)/.noinstall/skin.estouchy/* ${ADDON_BUILD}/${PKG_ADDON_ID}
}
