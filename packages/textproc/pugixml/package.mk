# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="pugixml"
PKG_VERSION="1.12.1"
PKG_SHA256="1e28ab24b6e04e013d96f45d25e9f2d04c921dc68c613fd010ecaaad3892c14d"
PKG_LICENSE="MIT"
PKG_SITE="https://pugixml.org/"
PKG_URL="https://github.com/zeux/pugixml/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Light-weight, simple and fast XML parser for C++ with XPath support."
PKG_BUILD_FLAGS="+pic"
