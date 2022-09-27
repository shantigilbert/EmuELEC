# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020 present Team CoreELEC (https://coreelec.org)

PKG_NAME="splash-image"
PKG_VERSION="918f0cf9f35ef67e4d340c7ad28d4bba7e442d7d"
PKG_SHA256="bf32728be517584cfeeb59877d4366978878c67c2f582d6dc2e4a788cd6d24cd"
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
