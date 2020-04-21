# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="pvr.iptvarchive"
PKG_VERSION="3.9.8-Leia"
PKG_SHA256="0812e359a943f4ffb763b47fc0440768a8aa09f12172ef8dff4440b0a48f9c96"
PKG_REV="2"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/kodi-pvr/pvr.iptvsimple"
PKG_URL="https://github.com/kodi-pvr/pvr.iptvsimple/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain kodi-platform rapidxml zlib"
PKG_SECTION=""
PKG_SHORTDESC="pvr.iptvarchive"
PKG_LONGDESC="pvr.iptvarchive"

PKG_IS_ADDON="yes"
PKG_ADDON_TYPE="xbmc.pvrclient"

PKG_CMAKE_OPTS_TARGET="-DRAPIDXML_INCLUDE_DIRS=$(get_build_dir rapidxml)"

post_patch() {
	[ -d "${PKG_BUILD}/pvr.iptvsimple" ] && mv "${PKG_BUILD}/pvr.iptvsimple" "${PKG_BUILD}/pvr.iptvarchive"
}
