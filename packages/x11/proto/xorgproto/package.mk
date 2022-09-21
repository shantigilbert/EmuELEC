# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="xorgproto"
PKG_VERSION="2022.1"
PKG_SHA256="1d2dcc66963f234d2c1e1f8d98a0d3e8725149cdac0a263df4097593c48bc2a6"
PKG_LICENSE="OSS"
PKG_SITE="http://www.X.org"
PKG_URL="https://xorg.freedesktop.org/archive/individual/proto/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain util-macros"
PKG_LONGDESC="combined X.Org X11 Protocol headers"
PKG_TOOLCHAIN="meson"

PKG_MESON_OPTS_TARGET="-Dlegacy=false \
                       -Dpkgconfigdatadir=/usr/lib/pkgconfig"
