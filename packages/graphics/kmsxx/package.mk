# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="kmsxx"
PKG_VERSION="2236a8ccacdfed5ff5f6873ed6618eccf570193d"
PKG_SHA256="774d25c7da4989b3183b50c04c80d8894e962f99215be7f0b01c593edf8afb20"
PKG_LICENSE="MPL-2.0"
PKG_SITE="https://github.com/tomba/kmsxx"
PKG_URL="https://github.com/tomba/kmsxx/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libdrm libfmt"
PKG_LONGDESC="Library and utilities for kernel mode setting"
PKG_BUILD_FLAGS="-sysroot"

PKG_MESON_OPTS_TARGET="-Ddefault_library=static \
                       -Dkmscube=false \
                       -Domap=disabled \
                       -Dpykms=disabled"

