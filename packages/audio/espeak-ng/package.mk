# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="espeak-ng"
PKG_VERSION="1.51"
PKG_SHA256="027fa5dfa8616d5cc13f883209ff5f735eee6559f7689a019d5b2d01d290cd39"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/espeak-ng/espeak-ng"
PKG_URL="https://github.com/espeak-ng/espeak-ng/releases/download/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="gcc:host "
PKG_DEPENDS_TARGET="toolchain espeak-ng:host"
PKG_LONGDESC="eSpeak NG is an open source speech synthesizer that supports more than a hundred languages and accents"
PKG_TOOLCHAIN="configure"

pre_configure() {
  cd ..
  make distclean
  ./autogen.sh
}

make_host() {
  make -j1
}

make_target() {
  make src/espeak-ng src/speak-ng
}

makeinstall_target() {
  make src/espeak-ng src/speak-ng
  make install-exec DESTDIR=${INSTALL}
  mkdir -p ${INSTALL}/usr/share/espeak-ng-data
  cp -prf ${TOOLCHAIN}/share/espeak-ng-data ${INSTALL}/usr/share
}

