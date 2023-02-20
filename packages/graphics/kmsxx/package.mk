# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="kmsxx"
PKG_VERSION="adc05b66548d10ad8c4a400fb8e8b072a2fd8e2c" # 2022-11-05
PKG_SHA256="a88cbaabac63738a51aabe62c1de11960a72ec2c2a29c436c820ae8c22a92b49"
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

