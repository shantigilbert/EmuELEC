# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="audiodecoder.timidity"
PKG_VERSION="2.0.5-Leia"
PKG_SHA256="b20a3a23056aaf76c216c755f36dff03e943d7c086d3e3fca4c920b93113e073"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/xbmc/audiodecoder.timidity"
PKG_URL="https://github.com/xbmc/audiodecoder.timidity/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform"
PKG_SECTION=""
PKG_SHORTDESC="audiodecoder.timidity"
PKG_LONGDESC="audiodecoder.timidity"

PKG_IS_ADDON="yes"
PKG_ADDON_TYPE="kodi.audiodecoder"

addon() {
  install_binary_addon $PKG_ADDON_ID

  mkdir -p $ADDON_BUILD/$PKG_ADDON_ID
    cp -P $PKG_BUILD/.$TARGET_NAME/lib/timidity/libtimidity_*.so $ADDON_BUILD/$PKG_ADDON_ID/
}
