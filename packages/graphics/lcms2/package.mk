# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="lcms2"
PKG_VERSION="2.13.1"
PKG_SHA256="d473e796e7b27c5af01bd6d1552d42b45b43457e7182ce9903f38bb748203b88"
PKG_LICENSE="MIT/GPLv3"
PKG_SITE="http://www.littlecms.com"
PKG_URL="https://github.com/mm2/Little-CMS/releases/download/lcms${PKG_VERSION}/lcms2-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain tiff"
PKG_LONGDESC="An small-footprint color management engine, with special focus on accuracy and performance."
PKG_BUILD_FLAGS="+pic"
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--disable-shared \
                           --enable-static"
