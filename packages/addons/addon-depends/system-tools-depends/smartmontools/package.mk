# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="smartmontools"
PKG_VERSION="7.3"
PKG_SHA256="a544f8808d0c58cfb0e7424ca1841cb858a974922b035d505d4e4c248be3a22b"
PKG_LICENSE="GPL"
PKG_SITE="https://www.smartmontools.org"
PKG_URL="https://downloads.sourceforge.net/sourceforge/smartmontools/smartmontools-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Control and monitor storage systems using S.M.A.R.T."
PKG_BUILD_FLAGS="-sysroot"

PKG_CONFIGURE_OPTS_TARGET="--prefix=/usr \
                           --without-initscriptdir \
                           --without-nvme-devicescan \
                           --without-systemdenvfile \
                           --without-systemdsystemunitdir \
                           --without-systemdenvfile \
                           --without-systemdsystemunitdir"
