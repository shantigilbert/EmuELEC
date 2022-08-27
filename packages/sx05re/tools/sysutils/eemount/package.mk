# SPDX-License-Identifier: GPL-3.0
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="eemount"
PKG_VERSION="4adf31387a9019cb07db861374839d496f2c95e5"
PKG_SHA256="84b0acb5f3c34a28ddc9e933b50fb2a395b0c044fcc300c79a97f405b0c03773"
PKG_SITE="https://github.com/7Ji/eemount"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain systemd"
PKG_LONGDESC="Multi-source ROMs mounting utility for EmuELEC"
PKG_TOOLCHAIN="make"
PKG_MAKE_OPTS_TARGET="LOGGING_ALL_TO_STDOUT=1"
