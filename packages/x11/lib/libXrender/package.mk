# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libXrender"
PKG_VERSION="0.9.10"
PKG_SHA256="c06d5979f86e64cabbde57c223938db0b939dff49fdb5a793a1d3d0396650949"
PKG_LICENSE="OSS"
PKG_SITE="http://www.X.org"
PKG_URL="http://xorg.freedesktop.org/archive/individual/lib/$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_DEPENDS_TARGET="toolchain util-macros libX11"
PKG_LONGDESC="The X Rendering Extension introduces digital image composition within the X Window System."
PKG_BUILD_FLAGS="+pic"

PKG_CONFIGURE_OPTS_TARGET="--enable-static --enable-shared --enable-malloc0returnsnull"
