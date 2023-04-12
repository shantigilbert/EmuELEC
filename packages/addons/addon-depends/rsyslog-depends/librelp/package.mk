# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="librelp"
PKG_VERSION="1.10.0"
PKG_SHA256="148db4e4d1a23e8136e9ec08810929a55faf5d45e24c2e3186d5ab34355dab31"
PKG_LICENSE="GPL"
PKG_SITE="https://www.rsyslog.com/category/librelp/"
PKG_URL="https://download.rsyslog.com/librelp/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Provides reliable event logging over the network."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+pic"

PKG_CONFIGURE_OPTS_TARGET="--enable-static \
                           --disable-shared \
                           --disable-tls \
                           ac_cv_func_malloc_0_nonnull=yes \
                           ac_cv_func_realloc_0_nonnull=yes"
