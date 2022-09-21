# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="stress-ng"
PKG_VERSION="0.14.03"
PKG_SHA256="95012c62883ab5826e6157557a075df98cce3cbce2a48bb40851bcc968a8441a"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/ColinIanKing/stress-ng"
PKG_URL="https://github.com/ColinIanKing/stress-ng/archive/refs/tags/V${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain attr keyutils libaio libcap zlib"
PKG_LONGDESC="stress-ng will stress test a computer system in various selectable ways"
PKG_BUILD_FLAGS="-sysroot"
