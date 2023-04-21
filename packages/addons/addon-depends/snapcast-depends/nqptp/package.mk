# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="nqptp"
PKG_VERSION="c71b49a3556ba8547ee28482cb31a97fe99298aa"
PKG_SHA256="02ed710ed37269adbede06fcd4e12892cc0f9d14d5c68b7f45d67b8694bff1e4"
PKG_LICENSE="GPL-2.0"
PKG_SITE="https://github.com/mikebrady/nqptp"
PKG_URL="https://github.com/mikebrady/nqptp/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Not Quite PTP"
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-sysroot"

PKG_CONFIGURE_OPTS_TARGET="--with-systemd-startup"
