# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020 present Team CoreELEC (https://coreelec.org)

PKG_NAME="splash-image"
PKG_VERSION="8cd52bd7d422ee31f1a6d1d48ae0b89ca179abdb"
PKG_SHA256="533f9dbf984d8f68ce38740027cba55a9e91241e3dac224e084dfea8b33b6644"
PKG_LICENSE="GPL"
PKG_SITE="https://coreelec.org"
PKG_URL="https://github.com/CoreELEC/splash-image/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_INIT="toolchain gcc:init glibc libspng zlib"
PKG_LONGDESC="Boot splash screen supporting animation by single RGBA png files"

makeinstall_init() {
  mkdir -p $INSTALL/usr/bin
    cp splash-image $INSTALL/usr/bin

  mkdir -p $INSTALL/splash/progress
    find_file_path "splash/splash-*.png" && cp ${FOUND_PATH} $INSTALL/splash || :
    find_file_path "splash/progress/splash-*" && cp ${FOUND_PATH} $INSTALL/splash/progress || :
}
