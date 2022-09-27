# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libxcvt"
PKG_VERSION="0.1.1"
PKG_SHA256="27ebce180d355f94c1992930bedb40a36f6d7312ee50bf7f0acbcd22f33e8c29"
PKG_LICENSE="OSS"
PKG_SITE="https://gitlab.freedesktop.org/xorg/lib/libxcvt"
PKG_URL="https://www.x.org/archive/individual/lib/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libxcvt is a library providing a standalone version of the X server implementation of the VESA CVT standard timing modelines generator."
PKG_BUILD_FLAGS="+pic"
