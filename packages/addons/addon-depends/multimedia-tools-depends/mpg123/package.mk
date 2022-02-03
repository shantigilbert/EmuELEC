# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mpg123"
PKG_VERSION="1.29.3"
PKG_SHA256="963885d8cc77262f28b77187c7d189e32195e64244de2530b798ddf32183e847"
PKG_LICENSE="LGPLv2"
PKG_SITE="http://www.mpg123.org/"
PKG_URL="http://downloads.sourceforge.net/sourceforge/mpg123/mpg123-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain alsa-lib"
PKG_LONGDESC="A console based real time MPEG Audio Player for Layer 1, 2 and 3."
PKG_BUILD_FLAGS="-sysroot"

PKG_CONFIGURE_OPTS_TARGET="--disable-shared \
                           --enable-static"
