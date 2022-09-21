# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="iperf"
PKG_VERSION="3.11"
PKG_SHA256="96e909c0d3ab6034c52328c2954fb3934aaff349395c4bc2611dcd50e6b89875"
PKG_LICENSE="BSD"
PKG_SITE="http://software.es.net/iperf/"
PKG_URL="https://github.com/esnet/iperf/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain openssl"
PKG_LONGDESC="A tool to measuring maximum TCP and UDP bandwidth performance."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-sysroot"

PKG_CONFIGURE_OPTS_TARGET="--enable-static \
                           --disable-shared"
