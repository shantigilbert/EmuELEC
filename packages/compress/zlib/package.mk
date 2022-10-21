# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="zlib"
PKG_VERSION="1.2.13"
PKG_SHA256="d14c38e313afc35a9a8760dadf26042f51ea0f5d154b0630a31da0540107fb98"
PKG_LICENSE="OSS"
PKG_SITE="http://www.zlib.net"
PKG_URL="http://zlib.net/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="cmake:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A general purpose (ZIP) data compression library."
PKG_TOOLCHAIN="cmake-make"

PKG_CMAKE_OPTS_HOST="-DINSTALL_PKGCONFIG_DIR=${TOOLCHAIN}/lib/pkgconfig"

PKG_CMAKE_OPTS_TARGET="-DINSTALL_PKGCONFIG_DIR=/usr/lib/pkgconfig"
