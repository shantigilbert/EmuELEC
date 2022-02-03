# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="espeak-ng"
PKG_VERSION="1.50"
PKG_SHA256="80ee6cd06fcd61888951ab49362b400e80dd1fac352a8b1131d90cfe8a210edb"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/espeak-ng/espeak-ng"
PKG_URL="https://github.com/espeak-ng/espeak-ng/releases/download/$PKG_VERSION/$PKG_NAME-$PKG_VERSION.tgz"
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
  make install-exec DESTDIR=$INSTALL
  mkdir -p $INSTALL/usr/share/espeak-ng-data
  cp -prf $TOOLCHAIN/share/espeak-ng-data $INSTALL/usr/share
}

