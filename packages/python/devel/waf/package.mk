# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="waf"
PKG_VERSION="2.0.24"
PKG_SHA256="6b78a3594540b232a154f64c4eb7e21f28e4e073c7e1605e4b9977519a6cb89e"
PKG_LICENSE="MIT"
PKG_SITE="https://waf.io"
PKG_URL="https://waf.io/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_LONGDESC="The Waf build system"
PKG_TOOLCHAIN="manual"

makeinstall_host() {
  cp -pf ${PKG_BUILD}/waf ${TOOLCHAIN}/bin/
}
